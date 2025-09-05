# How to Reset

## Quick Reset (Recommended)

```bash
# Reset migrations only (keeps DB2 running)
cd flyway
./run-flyway.sh clean
./run-flyway.sh migrate
```

## Full Reset Options

### Option 1: Reset Database Only
```bash
# Clean all tables and data
cd flyway
./run-flyway.sh clean

# Re-run migrations
./run-flyway.sh migrate

# Check status
./run-flyway.sh info
```

### Option 2: Restart DB2 Container
```bash
# Stop and remove DB2 container
docker stop db2-demo
docker rm db2-demo

# Start fresh DB2
docker run -d --name db2-demo \
  --platform linux/amd64 \
  -e LICENSE=accept \
  -e DB2INST1_PASSWORD=db2inst1-pwd \
  -e DBNAME=ICWADB \
  -p 50000:50000 \
  --privileged=true \
  icr.io/db2_community/db2

# Wait 2-3 minutes for DB2 to start
docker logs -f db2-demo

# Run migrations
cd flyway
./run-flyway.sh migrate
```

### Option 3: Complete Clean Start
```bash
# Remove everything
docker stop db2-demo
docker rm db2-demo
docker rmi flyway-db2  # Remove custom Flyway image

# Start over with Quick Start steps
```

## Flyway Commands

- `./run-flyway.sh clean` - Drop all database objects
- `./run-flyway.sh migrate` - Run all migrations
- `./run-flyway.sh info` - Show current status
- `./run-flyway.sh validate` - Check migration integrity
- `./run-flyway.sh repair` - Fix migration history

## Notes

- `clean` drops ALL objects in the schema (tables, data, everything)
- Flyway tracks migration history in `flyway_schema_history` table
- Each migration runs only once unless you clean first
- The custom Flyway Docker image is cached (rebuild with `docker rmi flyway-db2`)