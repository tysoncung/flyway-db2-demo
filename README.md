# DB2 + Flyway + .NET 9.0 on macOS ARM64

Simple solution for DB2 schema migrations on Apple Silicon Macs.

## Problem Solved

IBM DB2 drivers now support ARM64 architecture (Net.IBM.Data.Db2-osx 9.0.0.100), but IBM.EntityFrameworkCore doesn't support .NET 9.0 yet. Solution: Use Flyway for migrations.

## Quick Start

```bash
# 1. Start DB2
docker run -d --name db2-demo \
  --platform linux/amd64 \
  -e LICENSE=accept \
  -e DB2INST1_PASSWORD=db2inst1-pwd \
  -e DBNAME=ICWADB \
  -p 50000:50000 \
  --privileged=true \
  icr.io/db2_community/db2

# 2. Wait for DB2 to start (2-3 minutes)
docker logs -f db2-demo

# 3. Run Flyway migrations
cd flyway
./run-flyway.sh migrate  # Builds custom image with DB2 JDBC driver on first run

# 4. Check migration status
./run-flyway.sh info

# 5. Test connection from .NET 9.0
cd ..
./quick-demo.sh
```

## Flyway Setup

### Configuration
`flyway/flyway.conf`:
```properties
flyway.url=jdbc:db2://localhost:50000/ICWADB
flyway.user=db2inst1
flyway.password=db2inst1-pwd
flyway.locations=filesystem:./sql
```

### Migration Files
Place in `flyway/sql/`:
- `V1__Create_table.sql` - Version migrations
- `V2__Add_column.sql` - Incremental changes

### Commands
```bash
./run-flyway.sh info     # Show status
./run-flyway.sh migrate  # Run migrations
./run-flyway.sh validate # Validate
./run-flyway.sh clean    # Drop everything
```

## .NET 9.0 Application

```csharp
using IBM.Data.Db2;

var cs = "Server=localhost:50000;Database=ICWADB;UID=db2inst1;PWD=db2inst1-pwd;";
using var conn = new DB2Connection(cs);
conn.Open();
// Your code here
```

```xml
<PackageReference Include="Net.IBM.Data.Db2-osx" Version="9.0.0.100" />
```

## Why This Approach?

✅ Flyway handles migrations (no IBM.EntityFrameworkCore needed)  
✅ .NET 9.0 app runs natively on ARM64  
✅ Simple, proven, production-ready

## Demo

```bash
./demo-flyway.sh  # Full demo
./quick-demo.sh   # Quick test
```