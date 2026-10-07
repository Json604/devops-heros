# EC2: compute

**Name:** Kartikey  
**Roll number:** 24bcs10121

EC2 provides virtual machines. An AMI contains the operating system and launch image; an instance type chooses CPU, memory, networking and architecture. A `t3.micro` is x86_64; an ARM instance needs a matching ARM AMI. A key pair is used for SSH authentication, although Systems Manager can avoid opening SSH when its agent and IAM role are configured.

Security Groups are stateful allow rules attached to network interfaces. An allowed outbound request automatically permits its return traffic. EBS provides persistent block storage, can be encrypted, and supports snapshots. Root volume deletion on termination is configurable. Instance-store disks have different durability and should not be confused with EBS.

Private IPs are used inside a VPC; public IPv4 addresses allow internet reachability only when routes and security rules also permit it. An automatically assigned public IP may change after stop/start. Elastic IPs provide a stable allocation and have billing implications.

Lifecycle: pending -> running -> stopping -> stopped, or shutting-down -> terminated. Stopping does not remove EBS volumes or all associated charges. Reboot preserves the running instance allocation. Common uses include web services, build runners, batch jobs, and legacy applications.

The Session 19 instance serves Nginx, requires IMDSv2, uses encrypted root storage, and restricts HTTP to one administrator /32. It has no SSH ingress rule.

Reference: [EC2 concepts](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html).
