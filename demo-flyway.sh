#!/bin/bash

# Flyway Demo for DB2 with .NET 9.0 ARM64 Support

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=========================================="
echo "Flyway + DB2 + .NET 9.0 ARM64 Demo"
echo "==========================================${NC}"
echo ""

# Step 1: Show environment
echo -e "${BLUE}Environment:${NC}"
echo "  Architecture: $(uname -m)"
echo "  .NET Version: $(dotnet --version)"
echo ""

# Step 2: Check DB2 container
echo -e "${BLUE}DB2 Status:${NC}"
if docker ps | grep -q db2; then
    echo "  ✅ DB2 container is running"
else
    echo "  ❌ DB2 container is not running"
    echo "  Run: docker run -d --name db2-demo --platform linux/amd64 -e LICENSE=accept -e DB2INST1_PASSWORD=db2inst1-pwd -e DBNAME=ICWADB -p 50000:50000 --privileged=true icr.io/db2_community/db2"
    exit 1
fi
echo ""

# Step 3: Run Flyway
echo -e "${BLUE}Running Flyway Migrations:${NC}"
cd flyway

# Show migration files
echo "  Migration files:"
for file in sql/*.sql; do
    echo "    - $(basename $file)"
done
echo ""

# Check migration status
echo "  Current status:"
docker run --rm \
  --network host \
  -v "$(pwd):/flyway/conf" \
  -v "$(pwd)/sql:/flyway/sql" \
  flyway/flyway:10-alpine \
  -configFiles=/flyway/conf/flyway.conf \
  info 2>/dev/null | grep -E "^[0-9]|Pending|Success" || echo "    No migrations found"

echo ""
echo -e "${YELLOW}To run migrations:${NC}"
echo "  cd flyway"
echo "  ./run-flyway.sh migrate"
echo ""

echo -e "${YELLOW}Available Flyway commands:${NC}"
echo "  ./run-flyway.sh info     - Show migration status"
echo "  ./run-flyway.sh migrate  - Run pending migrations"
echo "  ./run-flyway.sh validate - Validate migrations"
echo "  ./run-flyway.sh clean    - Clean database (WARNING: drops all objects)"
echo ""

echo -e "${GREEN}=========================================="
echo "Why Flyway for DB2?"
echo "==========================================${NC}"
echo "✅ Industry standard migration tool"
echo "✅ Excellent DB2 support out of the box"
echo "✅ Version control friendly (plain SQL files)"
echo "✅ Works with any language/framework"
echo "✅ No dependency on IBM.EntityFrameworkCore"
echo ""
echo "Your .NET 9.0 app uses Net.IBM.Data.Db2-osx (ARM64)"
echo "Flyway handles the schema migrations independently"
echo "=========================================="${NC}