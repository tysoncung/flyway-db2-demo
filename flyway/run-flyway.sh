#!/bin/bash

# Run Flyway migrations using Docker with DB2 JDBC driver

echo "Running Flyway migrations for DB2..."

# Build custom Flyway image with DB2 driver if needed
if ! docker images | grep -q flyway-db2; then
    echo "Building Flyway image with DB2 JDBC driver..."
    docker build -t flyway-db2 .
fi

# Clean up any existing Flyway container
docker rm -f flyway-runner 2>/dev/null

# Run Flyway using custom image
docker run --rm \
  --name flyway-runner \
  --network host \
  -v "$(pwd):/flyway/conf" \
  -v "$(pwd)/sql:/flyway/sql" \
  flyway-db2 \
  -configFiles=/flyway/conf/flyway.conf \
  $@

# Examples:
# ./run-flyway.sh info     - Show migration status
# ./run-flyway.sh migrate  - Run migrations
# ./run-flyway.sh clean    - Clean database (WARNING: drops all objects)
# ./run-flyway.sh validate - Validate migrations