# Project Structure

```
.
├── flyway/                    # Flyway migration tool
│   ├── flyway.conf           # DB2 connection configuration
│   ├── run-flyway.sh         # Flyway runner script
│   └── sql/                  # SQL migration files
│       ├── V1__Create_policyholders_table.sql
│       ├── V2__Create_policies_table.sql
│       ├── V3__Create_claims_table.sql
│       └── V4__Insert_sample_data.sql
├── docker/
│   └── docker-compose.yml    # DB2 container setup
├── demo-flyway.sh            # Full Flyway demonstration
├── quick-demo.sh             # Quick DB2 connection test
└── README.md                 # Simple documentation
```

## Key Files

- **flyway/** - Database migration management
- **demo-flyway.sh** - Shows Flyway in action
- **quick-demo.sh** - Tests DB2 ARM64 support
- **docker-compose.yml** - DB2 container configuration

## Clean and Simple

This project demonstrates:
1. DB2 schema migrations using Flyway
2. .NET 9.0 with ARM64 support
3. No dependency on IBM.EntityFrameworkCore