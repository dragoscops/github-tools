#!/bin/bash

set -euo pipefail

show_help() {
  echo ""
  echo "Usage: $0 --app-id <id> --private-key <pem_file> --owner <org_or_user> --repo <repository> --workflow <filename> [--branch <branch>] [--inputs <inputs-as-json>]"
  echo ""
  echo "Required:"
  echo "  --app-id            GitHub App ID"
  echo "  --private-key       Path to private key PEM file"
  echo "  --owner             GitHub org/user that owns the repo"
  echo "  --repo              Target repository"
  echo "  --workflow          Workflow filename (e.g., ci.yml)"
  echo ""
  echo "Optional:"
  echo "  --branch            Branch to trigger (default: main)"
  echo "  --inputs            Inputs sent to the workflow in JSON format"
  echo "  --help              Show this help message"
  echo ""
  exit ${1:-0}
}

# Defaults
BRANCH="main"

# Parse arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
  --app-id)
    APP_ID="$2"
    shift
    ;;
  --private-key)
    PRIVATE_KEY_FILE="$2"
    shift
    ;;
  --owner)
    OWNER="$2"
    shift
    ;;
  --repo)
    REPO="$2"
    shift
    ;;
  --workflow)
    WORKFLOW_FILE="$2"
    shift
    ;;
  --branch)
    BRANCH="$2"
    shift
    ;;
  --workflow-inputs)
    WORKFLOW_INPUTS="$2"
    shift
    ;;
  --help | -h) show_help 0 ;;
  *)
    echo "❌ Unknown parameter passed: $1"
    show_help 1
    ;;
  esac
  shift
done

# Validate required
if [[ -z "${APP_ID:-}" || -z "${PRIVATE_KEY_FILE:-}" || -z "${OWNER:-}" || -z "${REPO:-}" || -z "${WORKFLOW_FILE:-}" ]]; then
  echo "❌ One or more required arguments are missing"
  show_help 1
fi

PARAMS="{\"ref\":\"$BRANCH\""
if [[ ! -z "$WORKFLOW_INPUTS" ]]; then PARAMS+=",\"inputs\":"; fi
PARAMS+="}"

echo "▶️ Arguments received:"
echo "  App ID:          $APP_ID"
echo "  Private key:     $PRIVATE_KEY_FILE"
echo "  Owner:           $OWNER"
echo "  Repo:            $REPO"
echo "  Workflow file:   $WORKFLOW_FILE"
echo "  Branch:          $BRANCH"
echo "  Dispatch Params: $PARAMS"
echo ""

exit 0

# Generate JWT
HEADER=$(echo -n '{"alg":"RS256","typ":"JWT"}' | base64 | tr -d '=' | tr '/+' '_-')
NOW=$(date +%s)
EXP=$((NOW + 600))
PAYLOAD=$(jq -n --arg iat "$NOW" --arg exp "$EXP" --arg iss "$APP_ID" \
  '{iat: ($iat | tonumber), exp: ($exp | tonumber), iss: $iss}' |
  base64 | tr -d '=' | tr '/+' '_-')
SIGNATURE=$(echo -n "$HEADER.$PAYLOAD" |
  openssl dgst -sha256 -sign "$PRIVATE_KEY_FILE" |
  base64 | tr -d '=' | tr '/+' '_-')
JWT="$HEADER.$PAYLOAD.$SIGNATURE"

# Fetch installation ID
echo "🔍 Fetching installation ID..."
INSTALLATION_ID=$(curl -s -H "Authorization: Bearer $JWT" -H "Accept: application/vnd.github+json" \
  https://api.github.com/app/installations | jq -r ".[] | select(.account.login==\"$OWNER\") | .id")

if [[ -z "$INSTALLATION_ID" || "$INSTALLATION_ID" == "null" ]]; then
  echo "❌ GitHub App is not installed on $OWNER"
  exit 1
fi
echo "✅ Found installation ID: $INSTALLATION_ID"

# Exchange JWT for an installation token
echo "🔑 Creating installation access token..."
INSTALL_TOKEN=$(curl -s -X POST \
  -H "Authorization: Bearer $JWT" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/app/installations/$INSTALLATION_ID/access_tokens | jq -r .token)

# Test repo access
echo "📂 Verifying access to $OWNER/$REPO..."
REPO_ACCESS=$(curl -s -H "Authorization: token $INSTALL_TOKEN" \
  https://api.github.com/repos/$OWNER/$REPO)

if echo "$REPO_ACCESS" | jq -e .id >/dev/null; then
  echo "✅ GitHub App has access to $OWNER/$REPO"
else
  echo "❌ App does not have access to $OWNER/$REPO"
  exit 1
fi

# Trigger the workflow
echo "🚀 Triggering workflow: $WORKFLOW_FILE on branch: $BRANCH"
TRIGGER_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
  -X POST \
  -H "Authorization: token $INSTALL_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/$OWNER/$REPO/actions/workflows/$WORKFLOW_FILE/dispatches \
  -d "$PARAMS")

if [[ "$TRIGGER_RESPONSE" == "204" ]]; then
  echo "🎉 Workflow successfully triggered!"
else
  echo "❌ Failed to trigger workflow (HTTP $TRIGGER_RESPONSE)"
  exit 1
fi
