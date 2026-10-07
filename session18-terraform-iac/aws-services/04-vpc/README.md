# VPC: networking

**Name:** Kartikey  
**Roll number:** 24bcs10121

A VPC is a logically isolated AWS network. Its CIDR defines its address range, for example `10.21.0.0/16`. Subnets divide that range and belong to individual Availability Zones. Route tables decide the next hop for a destination. The most specific matching route wins.

A public subnet has a route to an Internet Gateway. An instance also needs a public address and suitable security rules to be internet-reachable. A private subnet lacks a direct route to the Internet Gateway. A NAT Gateway lets private IPv4 workloads initiate outbound internet traffic through a public subnet, without accepting arbitrary inbound connections; it adds hourly and traffic charges.

Security Groups are stateful interface-level allow rules. Network ACLs are stateless subnet-level allow/deny rules, so return traffic and ephemeral ports need explicit consideration. Neither substitutes for application authentication.

The coursework VPC has two public subnets in different AZs, an Internet Gateway, a route table, and explicit associations. The EKS lab puts workers in those public subnets to avoid a NAT Gateway in a short-lived classroom deployment. A production architecture commonly uses private workers with controlled egress.

Reference: [VPC fundamentals](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html).
