#!/bin/bash

# Run Flyway natively (without Docker)
# Prerequisites: Download Flyway and DB2 JDBC driver

FLYWAY_VERSION="10.22.0"
FLYWAY_DIR="./flyway-$FLYWAY_VERSION"

# Check if Flyway is downloaded
if [ ! -d "$FLYWAY_DIR" ]; then
    echo "Downloading Flyway..."
    curl -L https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz -o flyway.tar.gz
    tar -xzf flyway.tar.gz
    rm flyway.tar.gz
    
    echo "Downloading DB2 JDBC driver..."
    curl -L https://repo1.maven.org/maven2/com/ibm/db2/jcc/11.5.9.0/jcc-11.5.9.0.jar \
         -o $FLYWAY_DIR/drivers/jcc.jar
fi

# Run Flyway
$FLYWAY_DIR/flyway \
    -url=jdbc:db2://localhost:50000/ICWADB \
    -user=db2inst1 \
    -password=db2inst1-pwd \
    -schemas=DB2INST1 \
    -locations=filesystem:./sql \
    -cleanDisabled=false \
    $@