# IAM: governance and access

**Name:** Kartikey
**Roll number:** 24bcs10121

IAM controls which AWS identities may perform which actions on which resources. A user is a long-lived identity; groups attach common policies to users. Roles are assumed temporarily by people, workloads or AWS services, and provide short-lived credentials through STS. A role is generally preferable to embedding an access key in code.

Policies are JSON permission statements with Effect, Action, Resource and optional Condition. Identity policies grant access to identities; resource policies attach to resources such as S3 buckets. An explicit deny overrides an allow. Permissions boundaries and organization controls can further restrict access; a boundary does not grant permission by itself.

Least privilege means granting only necessary actions and resource ARNs. A deployment role may need EKS operations without permission to manage billing or all IAM users. Use MFA for privileged users, protect the root account, avoid root access keys, prefer IAM Identity Center/federation for people, audit CloudTrail, and remove unused access. Use workload roles for EC2/EKS and OIDC trust restricted to the GitHub repository/environment for CI.

Common uses: EC2 reading a particular bucket, CI publishing infrastructure, and developers assuming a read-only troubleshooting role.

Reference: [AWS IAM introduction](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html).
