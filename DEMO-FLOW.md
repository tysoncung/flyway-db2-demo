# Demo Flow - DB2 + Flyway + .NET 9.0 ARM64

## 🎯 Key Story Points
1. **Problem**: IBM DB2 didn't work on Apple Silicon Macs
2. **Solution**: New ARM64-compatible driver + Flyway for migrations
3. **Result**: Native performance on M1/M2/M3 Macs

## 📋 Demo Script (5 minutes)

### 1️⃣ Show the Environment (30 seconds)
```bash
# Show we're on ARM64 Mac with .NET 9.0 ONLY
uname -m                    # Shows: arm64
dotnet --version            # Shows: 9.0.304
dotnet --list-runtimes      # Shows: Only .NET 9, no .NET 8!
```

**Say**: "We're running on Apple Silicon with only .NET 9.0 - no .NET 8 fallback"

### 2️⃣ Quick Connection Test (30 seconds)
```bash
# Prove DB2 works natively on ARM64
./quick-demo.sh
```

**Say**: "The new Net.IBM.Data.Db2-osx 9.0.0.100 package has native ARM64 support"

### 3️⃣ Show Migration Files (1 minute)
```bash
# Show the SQL migrations
ls -la flyway/sql/
cat flyway/sql/V1__Create_policyholders_table.sql
```

**Say**: "We use Flyway for migrations since IBM.EntityFrameworkCore doesn't support .NET 9 yet"

### 4️⃣ Run Migrations (2 minutes)
```bash
cd flyway

# Show current state (should be empty or show previous runs)
./run-flyway.sh info

# Clean if needed
./run-flyway.sh clean

# Run migrations
./run-flyway.sh migrate

# Show results
./run-flyway.sh info
```

**Say**: "Flyway handles version control and tracks what's been applied"

### 5️⃣ Verify in Database (1 minute)
```bash
# Check tables were created
docker exec db2-demo su - db2inst1 -c "db2 connect to ICWADB && db2 'list tables'"

# Show data was inserted
docker exec db2-demo su - db2inst1 -c "db2 connect to ICWADB && db2 'select * from POLICYHOLDERS'"
```

**Say**: "Tables created, data inserted, all managed by Flyway"

### 6️⃣ Show Integration (30 seconds)
```bash
# Show how .NET app would connect
cat README.md | grep -A 5 "\.NET 9\.0 Application"
```

**Say**: "Your .NET 9 app uses the ARM-native driver while Flyway manages schema"

## 🔄 Reset Between Demos
```bash
cd flyway
./run-flyway.sh clean
```

## 💬 Key Talking Points

### Why This Matters
- **Before**: Had to use x86 emulation for entire app (slow)
- **Now**: Native ARM64 performance for application code
- **Flyway**: Industry-standard migrations, no dependency on IBM's EF Core

### Architecture Benefits
- Application runs native ARM64
- Only DB2 server uses emulation (via Docker)
- Flyway is language-agnostic (works with any stack)

### Production Ready
- Flyway is battle-tested (used by Netflix, Amazon, etc.)
- Version control friendly (plain SQL files)
- Full rollback support
- CI/CD integration ready

## 🚀 Advanced Demo Options

### Show Rollback (if time permits)
```bash
# Create a new migration
echo "ALTER TABLE POLICYHOLDERS ADD COLUMN notes VARCHAR(500);" > flyway/sql/V5__Add_notes_column.sql

# Apply it
./run-flyway.sh migrate

# Show it worked
./run-flyway.sh info

# Rollback by cleaning and going to V4
./run-flyway.sh clean
rm flyway/sql/V5__Add_notes_column.sql
./run-flyway.sh migrate
```

### Show CI/CD Integration
```bash
# Flyway can run in CI/CD pipelines
docker run --rm \
  --network host \
  -v $(pwd):/flyway/conf \
  -v $(pwd)/sql:/flyway/sql \
  flyway-db2 \
  -configFiles=/flyway/conf/flyway.conf \
  validate
```

## 📊 Metrics to Highlight
- ✅ 100% native ARM64 execution for app code
- ✅ 0 dependencies on IBM.EntityFrameworkCore
- ✅ 4 migrations in < 1 second
- ✅ Works with .NET 9.0 (latest)

## 🎬 Demo Variations

### Quick Demo (2 minutes)
1. Run `./quick-demo.sh` - shows ARM64 working
2. Run `cd flyway && ./run-flyway.sh info` - shows migrations
3. Done!

### Technical Demo (10 minutes)
1. Explain architecture (show Docker, Flyway, .NET)
2. Walk through each migration file
3. Run migrations with detailed explanation
4. Show database internals
5. Demonstrate rollback/recovery

### Business Demo (5 minutes)
1. Focus on "it just works" on Mac
2. Show version control benefits
3. Emphasize production readiness
4. Compare to old approach (complexity)