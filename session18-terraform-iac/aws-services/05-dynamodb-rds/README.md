# DynamoDB and RDS

**Name:** Kartikey
**Roll number:** 24bcs10121

## DynamoDB

DynamoDB is a managed NoSQL key-value/document database. A table holds items, each composed of attributes. The partition key determines data distribution. An optional sort key distinguishes and orders items sharing a partition key. Design keys around access patterns; a poorly distributed key can produce hot partitions. Secondary indexes support alternate query patterns.

Use cases include session state, device events, shopping carts and predictable high-volume lookups. DynamoDB is not a drop-in relational database: joins and ad hoc relational queries need a different design. Choose on-demand or provisioned capacity according to traffic and cost needs.

## RDS

RDS manages relational database instances for engines such as PostgreSQL, MySQL, MariaDB, Oracle, SQL Server and Db2; Aurora is AWS's MySQL/PostgreSQL-compatible family. Availability, engine versions and licensing differ by region and edition. Tables have schemas and support relational constraints and SQL queries.

Place database instances in appropriate subnets, restrict Security Groups to the application, encrypt at rest and require TLS where configured, keep credentials in a secret manager, and apply engine updates. Automated backups support point-in-time recovery within retention limits; snapshots provide retained recovery points. Test restores rather than assuming a backup is useful.

Multi-AZ improves availability and failover. Traditional Multi-AZ standby instances are not read-scaling endpoints. Read replicas serve read-heavy workloads and may have replication lag; they do not automatically replace every high-availability configuration. Some newer Multi-AZ cluster architectures have readable instances, so distinguish the deployment type.

Use RDS for helpdesk records, finance, inventory and other relational workloads. The local capstone runs PostgreSQL on a PVC to demonstrate Kubernetes storage; a production deployment could use managed RDS with backups and restricted connectivity.

References: [DynamoDB concepts](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.CoreComponents.html), [RDS introduction](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Welcome.html).
