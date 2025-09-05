# Flyway in GitHub Actions

## ✅ Yes, Flyway works great in GitHub Actions!

## Quick Setup

### 1. Basic CI Pipeline
```yaml
name: CI
on: [push, pull_request]

jobs:
  migrate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Flyway
        run: |
          # Download Flyway
          wget -qO- https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/10.22.0/flyway-commandline-10.22.0-linux-x64.tar.gz | tar xz
          
          # Download DB2 driver
          mkdir -p flyway-10.22.0/drivers
          curl -L https://repo1.maven.org/maven2/com/ibm/db2/jcc/11.5.9.0/jcc-11.5.9.0.jar \
               -o flyway-10.22.0/drivers/jcc.jar
          
          # Run migrations
          cd flyway
          ../flyway-10.22.0/flyway migrate \
            -url="${{ secrets.DB_URL }}" \
            -user="${{ secrets.DB_USER }}" \
            -password="${{ secrets.DB_PASSWORD }}" \
            -locations=filesystem:./sql
```

### 2. Using Flyway Docker Action
```yaml
- name: Run Flyway
  uses: docker://flyway/flyway:10-alpine
  env:
    FLYWAY_URL: ${{ secrets.DB_URL }}
    FLYWAY_USER: ${{ secrets.DB_USER }}
    FLYWAY_PASSWORD: ${{ secrets.DB_PASSWORD }}
  with:
    args: migrate
```

## Provided Workflows

### 1. `flyway-migrations.yml` - CI/CD Pipeline
- ✅ Runs on push to main/develop
- ✅ Validates migrations on PRs
- ✅ Includes DB2 service container
- ✅ Tests with .NET 9
- ✅ Generates migration reports

### 2. `flyway-production.yml` - Production Deployment
- ✅ Manual trigger with environment selection
- ✅ Dry run option
- ✅ Staging vs Production configs
- ✅ Slack notifications
- ✅ Post-deployment reports

## GitHub Secrets Required

### For CI/CD
```
DB_URL=jdbc:db2://your-db:50000/ICWADB
DB_USER=db2inst1
DB_PASSWORD=your-password
```

### For Production
```
# Staging
STAGING_DB_HOST=staging.example.com
STAGING_DB_PORT=50000
STAGING_DB_NAME=ICWADB
STAGING_DB_USER=db2inst1
STAGING_DB_PASSWORD=xxx

# Production
PROD_DB_HOST=prod.example.com
PROD_DB_PORT=50000
PROD_DB_NAME=ICWADB
PROD_DB_USER=db2inst1
PROD_DB_PASSWORD=xxx

# Optional
SLACK_WEBHOOK=https://hooks.slack.com/xxx
```

## Common Patterns

### PR Validation Only
```yaml
on:
  pull_request:
    paths:
      - 'flyway/sql/**'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: flyway validate  # Check syntax only
      - run: flyway info      # Show what would run
```

### Auto-deploy to Staging
```yaml
on:
  push:
    branches: [develop]

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/checkout@v4
      - run: flyway migrate
```

### Manual Production Deploy
```yaml
on:
  workflow_dispatch:
    inputs:
      confirm:
        description: 'Type "DEPLOY" to confirm'
        required: true

jobs:
  deploy:
    if: github.event.inputs.confirm == 'DEPLOY'
    environment: production
    steps:
      - run: flyway migrate
```

## Best Practices

### 1. Use Environments
```yaml
environment: production  # Requires approval
```

### 2. Always Validate First
```yaml
- run: flyway validate
- run: flyway info
- run: flyway migrate  # Only if above pass
```

### 3. Generate Reports
```yaml
- run: flyway info -outputType=json > report.json
- uses: actions/upload-artifact@v3
  with:
    name: migration-report
    path: report.json
```

### 4. Use Service Containers for Testing
```yaml
services:
  db2:
    image: icr.io/db2_community/db2:11.5.9.0-community
    env:
      LICENSE: accept
      DB2INST1_PASSWORD: test
      DBNAME: TESTDB
```

## Alternative: Flyway CLI Action
```yaml
- uses: flywaydb/flyway-cli-action@v1
  with:
    url: ${{ secrets.DB_URL }}
    user: ${{ secrets.DB_USER }}
    password: ${{ secrets.DB_PASSWORD }}
    command: migrate
```

## Testing Locally with Act
```bash
# Install act
brew install act

# Run GitHub Actions locally
act -P ubuntu-latest=ghcr.io/catthehacker/ubuntu:full-20.04

# With secrets
act --secret-file .secrets
```

## Migration Strategy

### Development
- Auto-migrate on push to develop
- No approval required

### Staging
- Auto-migrate on merge to main
- Run full test suite after

### Production
- Manual trigger only
- Requires approval
- Dry run first
- Backup before migration

## Rollback Strategy
```yaml
- name: Rollback on failure
  if: failure()
  run: |
    flyway undo  # Requires Flyway Teams
    # OR
    flyway clean && flyway migrate -target=3  # Go to version 3
```

## Monitoring
```yaml
- name: Check migration status
  run: |
    STATUS=$(flyway info -outputType=json | jq '.migrations[-1].state')
    if [ "$STATUS" != '"Success"' ]; then
      exit 1
    fi
```