# S3: object storage

**Name:** Kartikey
**Roll number:** 24bcs10121

S3 stores objects inside buckets. Each object has a key, content, metadata and optionally a version ID. It is not a POSIX filesystem or a block device. Bucket names must satisfy the naming rules and be unique in the applicable namespace/partition.

Storage classes trade cost, availability characteristics, retrieval time and access charges: Standard for frequent access, Intelligent-Tiering for changing access patterns, Standard-IA/One Zone-IA for infrequent access, and Glacier classes for archives with different retrieval options. Choose based on access and recovery requirements rather than storage price alone.

Versioning preserves older object versions and delete markers. Lifecycle policies can transition objects or expire versions after defined ages. Server-side encryption can use S3-managed keys or KMS-managed keys; KMS supports additional key policy and audit controls. Bucket policies control resource access, and Block Public Access helps prevent accidental exposure.

The lab bucket blocks public access, enables versioning, configures AES256 server-side encryption and denies HTTP transport. `force_destroy=false` prevents Terraform from silently deleting a populated bucket. Versioned objects and delete markers must be deliberately removed before destruction.

Uses: backups, static assets, logs, data lakes and Terraform remote state with appropriate access control and locking.

Reference: [S3 overview](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html).
