### Usage Examples for the Composite Action

#### 1. **Creating a `.npmrc` File with Full Content:**

This example uses the `content` input to directly create or overwrite the entire `.npmrc` file.

```yaml
jobs:
  create-npmrc-file:
    runs-on: ubuntu-latest
    steps:
      - name: Create .npmrc file with full content
        uses: ./
        with:
          content: |
            email=foo@foo.com
            //foo.jfrog.io/artifactory/api/npm/foo-npm-virtual/:_authToken=<npm-token>
            @foo-scope1:registry=https://foo.jfrog.io/artifactory/api/npm/foo-npm-virtual/
```

#### 2. **Creating `.npmrc` File with Individual Records:**

This example uses the `records` input to create an `.npmrc` file with token configurations.

```yaml
jobs:
  create-npmrc-file:
    runs-on: ubuntu-latest
    steps:
      - name: Create .npmrc file with records
        uses: ./
        with:
          records: |
            [
              {
                "username": "foo@foo.com",
                "token": "<npm-token>",
                "scopes": ["@foo-scope1"],
                "registry": "https://foo.jfrog.io/artifactory/api/npm/foo-npm-virtual/"
              },
              {
                "username": "other.user@domain.com",
                "token": "<npm-token>",
                "scopes": [],
                "registry": "https://other-registry-url.com"
              }
            ]
```

#### 3. **Resetting `.npmrc` and Adding New Configurations:**

This example resets the existing `.npmrc` file and then writes new token configurations.

```yaml
jobs:
  create-npmrc-file:
    runs-on: ubuntu-latest
    steps:
      - name: Reset .npmrc and add new records
        uses: ./
        with:
          reset: true
          records: |
            [
              {
                "username": "foo@foo.com",
                "token": "<npm-token>",
                "scopes": ["@foo-scope1"],
                "registry": "https://foo.jfrog.io/artifactory/api/npm/foo-npm-virtual/"
              }
            ]
```

#### 4. **Creating `.npmrc` File without Scopes:**

This example demonstrates creating `.npmrc` file entries without specific scopes.

```yaml
jobs:
  create-npmrc-file:
    runs-on: ubuntu-latest
    steps:
      - name: Create .npmrc without scopes
        uses: ./
        with:
          records: |
            [
              {
                "username": "no.scope.user@domain.com",
                "token": "<npm-token>",
                "scopes": [],
                "registry": "https://no-scope-registry-url.com"
              }
            ]
```

These usage examples cover different scenarios, such as writing full content directly, adding token configurations, and resetting existing content, as well as handling different configurations in the `.npmrc` file.
