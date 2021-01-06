# install fedora-oracle to aws ec2

## terraform

## aws-cli

how to use
```shell
# show your vpc list in aws
aws ec2 describe-vpcs

# show your internet-gateway list in aws
aws ec2 describe-internet-gateways

# show route table list in aws
aws ec2 describe-route-tables

# show subnets list in aws
aws ec2 describe-subnets

# show your network-acl list in aws
aws ec2 describe-network-acls

# show your security-group list in aws
aws ec2 describe-security-groups

# show your elastic ip address list in aws
aws ec2 describe-addresses

# show ec2 assigned nic list in aws
aws ec2 describe-network-interfaces

# aws route53 list-resource-record-sets help
# aws route53 list-health-checks

# list policies
aws iam list-policies

aws iam list-users

aws iam list-access-keys

aws iam list-roles

aws iam list-groups

# show droplet image list
aws ec2 describe-images --owners amazon

aws ec2 describe-images --owners aws-marketplace

# show avairable instance-type
aws ec2 describe-instance-types

# show region list
## use lightsail command
aws lightsail get-regions
aws ecn2 describe-regions

# shoe availability zone
## use ec2 command
aws ec2 describe-availability-zones

# shoe project list

# show exists your ssh-key in digital-ocean
aws ec2 describe-key-pairs

# show aws existing your ec2 instance.
aws ec2 describe-instances

# connect
# if you have not yet install EC2 Instance Connect CLI, you execute below command
# pip3 install ec2instanceconnectcli
# instance ID
mssh fedora@*instance-id*
```