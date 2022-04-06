# Connecting to DocumentDB across VPC

This project demonstrates a technique to connect to an Amazon DocumentDB cluster using VPC endpoint 
service from across another VPC. This eliminates need for peering the VPCs, which is often viewed
as complex and unsafe. The client VPC can be located in another AWS account as well. Currently, 
VPC endpoints only work within a single AWS region, however a future update will enable cross-region
support for VPC endpoints using AWS PrivateLink. 

# Architecture

The following diagram shows the design implemented in this project: 
<br/><img src="diagram.png" width="821"/><br/>
[Figure 1: AWS architecture diagram showing DocumentDB access across VPC](diagram.png)


## TODO

Following features have not been implemented in this project as yet: 

1. Implement a Lambda function to detect for DocumentDB cluster IP address changes and update NLB targets
2. Optimize NLB health check settings to perform faster registration/deregistration of DocumentDB instances
