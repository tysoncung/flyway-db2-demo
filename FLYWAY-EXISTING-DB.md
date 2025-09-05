# Adding Flyway to an Existing Database

## The Problem
When you baseline Flyway on an existing database, it marks a specific version as "already applied" without actually running those migrations. In your case:
- V1 was marked as "baseline" (skipped)
- V2 tries to reference POLICYHOLDERS table (which V1 would have created)
- Error: POLICYHOLDERS doesn't exist

## Solution Options

### Option 1: Baseline at Current State (Recommended)
If your database already has all tables and you want Flyway to manage FUTURE changes only:

```bash
# 1. Check what tables exist in your database
docker exec db2-demo su - db2inst1 -c "db2 connect to ICWADB && db2 'list tables'"

# 2. Create a baseline script that represents current state
echo "-- V1__Baseline_existing_schema.sql
-- This migration represents the existing database state
-- No actual DDL needed as tables already exist" > flyway/sql/V1__Baseline_existing_schema.sql

# 3. Move other migrations to start from V2 or higher
cd flyway/sql
mv V1__Create_policyholders_table.sql old/
mv V2__Create_policies_table.sql V10__Create_policies_table.sql
mv V3__Create_claims_table.sql V11__Create_claims_table.sql
# etc...

# 4. Clean Flyway history and baseline at version 1
./run-flyway.sh repair
./run-flyway.sh baseline -baselineVersion=1 -baselineDescription="Existing_schema"

# 5. Now run new migrations
./run-flyway.sh migrate
```

### Option 2: Start Fresh (Clean Slate)
If you want Flyway to manage everything from scratch:

```bash
# 1. Clean everything (WARNING: This drops ALL objects!)
./run-flyway.sh clean

# 2. Run all migrations from V1
./run-flyway.sh migrate
```

### Option 3: Conditional Migrations
Make your migrations idempotent (safe to run multiple times):

```sql
-- V1__Create_policyholders_table.sql
-- Check if table exists before creating
CREATE TABLE IF NOT EXISTS POLICYHOLDERS (
    ID INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    -- ... rest of columns
);
```

Note: DB2 doesn't support IF NOT EXISTS, so you'd need a stored procedure:

```sql
-- V1__Create_policyholders_table.sql
BEGIN
  DECLARE CONTINUE HANDLER FOR SQLSTATE '42710' 
    BEGIN END;
  
  EXECUTE IMMEDIATE 'CREATE TABLE POLICYHOLDERS (
    ID INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    POLICYHOLDER_CODE VARCHAR(50) NOT NULL,
    -- ... rest of columns
  )';
END
```

### Option 4: Baseline After Existing Tables
Most common approach for existing databases:

```bash
# 1. First, check what's in your database
docker exec db2-demo su - db2inst1 -c "db2 connect to ICWADB && db2 'SELECT TABNAME FROM SYSCAT.TABLES WHERE TABSCHEMA = CURRENT_SCHEMA'"

# 2. If POLICYHOLDERS already exists, baseline AFTER it
./run-flyway.sh repair  # Clean up failed migration
./run-flyway.sh baseline -baselineVersion=4 -baselineDescription="After_initial_tables"

# 3. Rename future migrations to start from V5
cd flyway/sql
mv V5__Create_user_table.sql V5__Create_user_table.sql  # Keep as is
mv V6__Create_Store_procedure.sql V6__Create_Store_procedure.sql  # Keep as is
# etc...

# 4. Run migrations (will start from V5)
./run-flyway.sh migrate
```

## Best Practice for Existing Databases

### Step 1: Document Current State
```bash
# Export current schema
docker exec db2-demo su - db2inst1 -c "db2look -d ICWADB -e -o current_schema.sql"
```

### Step 2: Create Baseline Migration
```sql
-- V1__Baseline_existing_production_schema.sql
-- Captured on: 2025-09-02
-- This represents the production database as of baseline date
-- All objects before this point already exist
```

### Step 3: Configure Flyway
```properties
# flyway.conf
flyway.baselineVersion=1
flyway.baselineDescription=Production_baseline_2025_09_02
flyway.baselineOnMigrate=true
```

### Step 4: Future Migrations Start from V2
```sql
-- V2__Add_new_feature.sql
-- All new changes go here
ALTER TABLE EXISTING_TABLE ADD COLUMN NEW_COLUMN VARCHAR(100);
```

## Your Specific Fix

Based on your error, POLICYHOLDERS doesn't exist. You have two choices:

### Quick Fix - Run V1 Manually Then Continue
```bash
# 1. Create POLICYHOLDERS manually
docker exec db2-demo su - db2inst1 -c "db2 connect to ICWADB && db2 -tvf /path/to/V1__Create_policyholders_table.sql"

# 2. Tell Flyway to continue from V2
./run-flyway.sh repair
./run-flyway.sh migrate
```

### Proper Fix - Reset and Start Over
```bash
# 1. Clean up the failed state
./run-flyway.sh repair

# 2. If you want a clean start
./run-flyway.sh clean  # WARNING: Drops everything!

# 3. Run all migrations
./run-flyway.sh migrate
```

## Common Patterns

### For Brand New Development Database
```bash
./run-flyway.sh clean
./run-flyway.sh migrate
```

### For Existing Production Database
```bash
# Don't run old migrations, baseline at current state
./run-flyway.sh baseline -baselineVersion=100 -baselineDescription="Prod_baseline"
# New migrations start from V101
```

### For Partially Migrated Database
```bash
# Check what's applied
./run-flyway.sh info

# Repair if needed
./run-flyway.sh repair

# Continue from where it left off
./run-flyway.sh migrate
```

## Key Commands

- `info` - Shows current state
- `baseline` - Mark a version as already applied
- `repair` - Fix schema history inconsistencies  
- `clean` - Drop everything (DANGEROUS!)
- `migrate` - Run pending migrations
- `validate` - Check migrations are valid