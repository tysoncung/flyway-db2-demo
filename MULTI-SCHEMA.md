# Flyway Multi-Schema Management

## Option 1: Multiple Schemas in One Project

### Configuration
```properties
# flyway.conf
flyway.url=jdbc:db2://localhost:50000/ICWADB
flyway.user=db2inst1
flyway.password=db2inst1-pwd

# Manage multiple schemas
flyway.schemas=SCHEMA1,SCHEMA2,SCHEMA3

# First schema is the default for flyway_schema_history table
flyway.defaultSchema=SCHEMA1

# Apply migrations to all schemas
flyway.locations=filesystem:./sql/common,filesystem:./sql/schema1,filesystem:./sql/schema2
```

### Directory Structure
```
flyway/
├── sql/
│   ├── common/          # Migrations for all schemas
│   │   ├── V1__Create_base_tables.sql
│   │   └── V2__Add_indexes.sql
│   ├── schema1/          # Schema1-specific
│   │   └── V1_1__Schema1_specific.sql
│   ├── schema2/          # Schema2-specific
│   │   └── V1_2__Schema2_specific.sql
│   └── schema3/          # Schema3-specific
│       └── V1_3__Schema3_specific.sql
└── flyway.conf
```

### Migration Examples

#### Cross-Schema Migration
```sql
-- V1__Create_cross_schema_tables.sql
-- Creates tables in multiple schemas

-- Schema 1 tables
CREATE TABLE SCHEMA1.USERS (
    ID INTEGER PRIMARY KEY,
    NAME VARCHAR(100)
);

-- Schema 2 tables
CREATE TABLE SCHEMA2.PRODUCTS (
    ID INTEGER PRIMARY KEY,
    NAME VARCHAR(100)
);

-- Schema 3 tables
CREATE TABLE SCHEMA3.ORDERS (
    ID INTEGER PRIMARY KEY,
    USER_ID INTEGER,
    PRODUCT_ID INTEGER
);
```

#### Schema-Specific Migration
```sql
-- V2__Add_schema_specific_objects.sql
-- Use placeholders for schema names

CREATE TABLE ${schema1}.AUDIT_LOG (
    ID INTEGER PRIMARY KEY,
    ACTION VARCHAR(50)
);

CREATE VIEW ${schema2}.USER_PRODUCTS AS
SELECT u.*, p.*
FROM ${schema1}.USERS u
JOIN ${schema3}.ORDERS o ON u.ID = o.USER_ID
JOIN ${schema2}.PRODUCTS p ON p.ID = o.PRODUCT_ID;
```

## Option 2: Separate Configurations per Schema

### Multiple Config Files
```bash
flyway/
├── conf/
│   ├── schema1.conf
│   ├── schema2.conf
│   └── schema3.conf
├── sql/
│   ├── schema1/
│   ├── schema2/
│   └── schema3/
└── run-migrations.sh
```

### schema1.conf
```properties
flyway.url=jdbc:db2://localhost:50000/ICWADB
flyway.schemas=SCHEMA1
flyway.defaultSchema=SCHEMA1
flyway.locations=filesystem:./sql/schema1
flyway.table=schema1_history
```

### schema2.conf
```properties
flyway.url=jdbc:db2://localhost:50000/ICWADB
flyway.schemas=SCHEMA2
flyway.defaultSchema=SCHEMA2
flyway.locations=filesystem:./sql/schema2
flyway.table=schema2_history
```

### Run Script
```bash
#!/bin/bash
# run-migrations.sh

# Run migrations for each schema
for schema in schema1 schema2 schema3; do
    echo "Migrating $schema..."
    flyway -configFiles="conf/$schema.conf" migrate
done
```

## Option 3: Schema Variables with Placeholders

### Configuration with Placeholders
```properties
# flyway.conf
flyway.url=jdbc:db2://localhost:50000/ICWADB
flyway.placeholders.schema1=ACCOUNTS
flyway.placeholders.schema2=INVENTORY
flyway.placeholders.schema3=SALES
```

### Migration Using Placeholders
```sql
-- V1__Create_multi_schema_structure.sql

-- Accounts schema
CREATE TABLE ${schema1}.CUSTOMERS (
    ID INTEGER PRIMARY KEY,
    NAME VARCHAR(100)
);

-- Inventory schema
CREATE TABLE ${schema2}.PRODUCTS (
    ID INTEGER PRIMARY KEY,
    SKU VARCHAR(50)
);

-- Sales schema
CREATE TABLE ${schema3}.ORDERS (
    ID INTEGER PRIMARY KEY,
    CUSTOMER_ID INTEGER,
    FOREIGN KEY (CUSTOMER_ID) 
        REFERENCES ${schema1}.CUSTOMERS(ID)
);
```

## Option 4: Environment-Specific Schemas

### Development vs Production
```bash
# dev.conf
flyway.schemas=DEV_SCHEMA1,DEV_SCHEMA2
flyway.defaultSchema=DEV_SCHEMA1

# prod.conf
flyway.schemas=PROD_SCHEMA1,PROD_SCHEMA2
flyway.defaultSchema=PROD_SCHEMA1
```

### Run with Environment
```bash
# Development
flyway -configFiles=dev.conf migrate

# Production
flyway -configFiles=prod.conf migrate
```

## Best Practices for Multi-Schema

### 1. Schema Isolation
```sql
-- Keep schemas independent where possible
-- V1__Schema1_only.sql
CREATE TABLE SCHEMA1.USERS (
    ID INTEGER PRIMARY KEY
);

-- V2__Schema2_only.sql
CREATE TABLE SCHEMA2.PRODUCTS (
    ID INTEGER PRIMARY KEY
);
```

### 2. Cross-Schema References
```sql
-- V3__Cross_schema_views.sql
-- Document dependencies clearly
CREATE VIEW SCHEMA1.ORDER_SUMMARY AS
SELECT 
    o.ID,
    c.NAME as CUSTOMER,
    p.NAME as PRODUCT
FROM SCHEMA3.ORDERS o
JOIN SCHEMA1.CUSTOMERS c ON o.CUSTOMER_ID = c.ID
JOIN SCHEMA2.PRODUCTS p ON o.PRODUCT_ID = p.ID;
```

### 3. Schema Creation
```sql
-- V0__Create_schemas.sql
-- Run once to create all schemas
CREATE SCHEMA IF NOT EXISTS SCHEMA1;
CREATE SCHEMA IF NOT EXISTS SCHEMA2;
CREATE SCHEMA IF NOT EXISTS SCHEMA3;

-- Grant permissions
GRANT ALL ON SCHEMA SCHEMA1 TO db2inst1;
GRANT ALL ON SCHEMA SCHEMA2 TO db2inst1;
GRANT ALL ON SCHEMA SCHEMA3 TO db2inst1;
```

## Real-World Example: Microservices

### Shared Database, Separate Schemas
```
ICWADB Database
├── USER_SERVICE schema
│   ├── USERS table
│   └── USER_PROFILES table
├── PRODUCT_SERVICE schema
│   ├── PRODUCTS table
│   └── INVENTORY table
├── ORDER_SERVICE schema
│   ├── ORDERS table
│   └── ORDER_ITEMS table
└── COMMON schema
    ├── AUDIT_LOG table
    └── CONFIGURATIONS table
```

### Configuration
```properties
# flyway.conf for microservices
flyway.url=jdbc:db2://localhost:50000/ICWADB
flyway.schemas=USER_SERVICE,PRODUCT_SERVICE,ORDER_SERVICE,COMMON
flyway.defaultSchema=COMMON
flyway.locations=filesystem:./sql/common,filesystem:./sql/services

# Placeholders for flexibility
flyway.placeholders.userSchema=USER_SERVICE
flyway.placeholders.productSchema=PRODUCT_SERVICE
flyway.placeholders.orderSchema=ORDER_SERVICE
flyway.placeholders.commonSchema=COMMON
```

### Migration Script
```sql
-- V1__Setup_microservices.sql
-- User Service
CREATE TABLE ${userSchema}.USERS (
    ID INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    EMAIL VARCHAR(255) UNIQUE NOT NULL,
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Product Service
CREATE TABLE ${productSchema}.PRODUCTS (
    ID INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    SKU VARCHAR(100) UNIQUE NOT NULL,
    NAME VARCHAR(255),
    PRICE DECIMAL(10,2)
);

-- Order Service with cross-schema FK
CREATE TABLE ${orderSchema}.ORDERS (
    ID INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    USER_ID INTEGER NOT NULL,
    TOTAL DECIMAL(10,2),
    -- Cross-schema reference
    FOREIGN KEY (USER_ID) REFERENCES ${userSchema}.USERS(ID)
);

-- Common audit for all services
CREATE TABLE ${commonSchema}.AUDIT_LOG (
    ID INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    SCHEMA_NAME VARCHAR(50),
    TABLE_NAME VARCHAR(50),
    ACTION VARCHAR(20),
    USER_ID INTEGER,
    TIMESTAMP TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## GitHub Actions for Multi-Schema

```yaml
name: Multi-Schema Migration

on: [push]

jobs:
  migrate:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        schema: [user_service, product_service, order_service]
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Flyway for ${{ matrix.schema }}
        run: |
          flyway migrate \
            -configFiles=conf/${{ matrix.schema }}.conf \
            -url="${{ secrets.DB_URL }}" \
            -user="${{ secrets.DB_USER }}" \
            -password="${{ secrets.DB_PASSWORD }}"
```

## Advantages of Multi-Schema

1. **Logical Separation**: Keep different domains separate
2. **Security**: Different permissions per schema
3. **Microservices**: Each service owns its schema
4. **Multi-Tenant**: One schema per tenant
5. **Blue-Green Deployments**: Switch between schema versions

## Example for Your Project

```bash
# Modify your existing flyway.conf
flyway.schemas=DB2INST1,REPORTING,ANALYTICS
flyway.defaultSchema=DB2INST1

# Create schema-specific migrations
mkdir -p flyway/sql/reporting
mkdir -p flyway/sql/analytics

# Add to locations
flyway.locations=filesystem:./sql,filesystem:./sql/reporting,filesystem:./sql/analytics
```

Then you can create migrations like:
```sql
-- V20__Create_reporting_schema.sql
CREATE SCHEMA IF NOT EXISTS REPORTING;

CREATE TABLE REPORTING.MONTHLY_SUMMARY (
    ID INTEGER PRIMARY KEY,
    MONTH DATE,
    TOTAL_POLICIES INTEGER,
    TOTAL_CLAIMS DECIMAL(15,2)
);

-- Populate from main schema
INSERT INTO REPORTING.MONTHLY_SUMMARY
SELECT 
    ROW_NUMBER() OVER() as ID,
    DATE_TRUNC('month', CREATED_DATE) as MONTH,
    COUNT(*) as TOTAL_POLICIES,
    SUM(CLAIM_AMOUNT) as TOTAL_CLAIMS
FROM DB2INST1.POLICIES p
LEFT JOIN DB2INST1.CLAIMS c ON p.ID = c.POLICY_ID
GROUP BY DATE_TRUNC('month', CREATED_DATE);
```

This way, one Flyway project manages your main schema, reporting schema, and analytics schema all together!