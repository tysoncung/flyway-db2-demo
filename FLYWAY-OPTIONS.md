# Flyway Installation Options

## Option 1: Docker (Current Setup) ✅
**Pros:**
- No installation needed
- Consistent environment
- Easy cleanup
- Included DB2 driver

**Cons:**
- Requires Docker
- Slower startup
- Another container to manage

**Usage:**
```bash
cd flyway
./run-flyway.sh migrate
```

## Option 2: Native Installation (No Docker)
**Pros:**
- Faster execution
- No Docker required
- Direct control

**Cons:**
- Must install Flyway
- Must download DB2 JDBC driver
- Java required on your machine

### Install Native Flyway

#### Method A: Homebrew (macOS)
```bash
# Install Flyway
brew install flyway

# Download DB2 JDBC driver
curl -L https://repo1.maven.org/maven2/com/ibm/db2/jcc/11.5.9.0/jcc-11.5.9.0.jar \
     -o /usr/local/Cellar/flyway/*/libexec/drivers/jcc.jar

# Run migrations
flyway -configFiles=flyway.conf migrate
```

#### Method B: Manual Download
```bash
# Use the provided script
cd flyway
./run-flyway-native.sh migrate
```

This script automatically:
1. Downloads Flyway if not present
2. Downloads DB2 JDBC driver
3. Runs migrations

#### Method C: Direct Download
```bash
# Download Flyway
wget https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/10.22.0/flyway-commandline-10.22.0.tar.gz
tar -xzf flyway-commandline-10.22.0.tar.gz

# Download DB2 driver
curl -L https://repo1.maven.org/maven2/com/ibm/db2/jcc/11.5.9.0/jcc-11.5.9.0.jar \
     -o flyway-10.22.0/drivers/jcc.jar

# Run
./flyway-10.22.0/flyway -configFiles=flyway/flyway.conf migrate
```

## Option 3: Flyway CLI (Official)
```bash
# Install Flyway CLI
curl -L https://flywaydb.org/download/cli | sh

# Add DB2 driver to ~/.flyway/drivers/
mkdir -p ~/.flyway/drivers
curl -L https://repo1.maven.org/maven2/com/ibm/db2/jcc/11.5.9.0/jcc-11.5.9.0.jar \
     -o ~/.flyway/drivers/jcc.jar

# Run from project
flyway -configFiles=flyway/flyway.conf migrate
```

## Which Should You Use?

### Use Docker if:
- ✅ You want zero installation
- ✅ You already use Docker
- ✅ You want consistency across team
- ✅ You're doing a quick demo

### Use Native if:
- ✅ You run migrations frequently
- ✅ You want faster execution
- ✅ You don't want Docker dependency
- ✅ You're in production CI/CD

## Quick Test Commands

### Docker Version
```bash
cd flyway
./run-flyway.sh info
```

### Native Version
```bash
cd flyway
./run-flyway-native.sh info
# OR if installed via Homebrew
flyway -configFiles=flyway.conf info
```

## Requirements

### For Docker Version
- Docker Desktop

### For Native Version
- Java 11+ (check with `java -version`)
- Flyway binary
- DB2 JDBC driver

## Note on DB2 Container
**You still need Docker for DB2 itself** unless you have:
- DB2 installed locally (not available for macOS)
- Remote DB2 server
- DB2 in the cloud

The question is whether you run **Flyway** in Docker, not DB2.