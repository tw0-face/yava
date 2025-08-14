#!/bin/bash
set -e

echo "Fetching awslocal Network Resources (Concise Tables + Tags)..."

# 1. VPCs (concise, no State, with Tags)
echo -e "\n==== VPCs ===="
awslocal ec2 describe-vpcs \
  --query "Vpcs[].{VpcId:VpcId, Cidr:CidrBlock, Default:IsDefault, Tags:Tags}" \
  --output table

# Get non-default VPC IDs for use in later queries
NON_DEFAULT_VPCS=$(awslocal ec2 describe-vpcs \
  --query "Vpcs[?IsDefault==\`false\`].VpcId" \
  --output text)

# 2. Subnets in non-default VPCs (with tags)
echo -e "\n==== Subnets (non-default VPCs only) ===="
for VPC_ID in $NON_DEFAULT_VPCS; do
  awslocal ec2 describe-subnets \
    --filters Name=vpc-id,Values=$VPC_ID \
    --query "Subnets[].{SubnetId:SubnetId, VpcId:VpcId, AZ:AvailabilityZone, CIDR:CidrBlock, Tags:Tags}" \
    --output table
done

# 3. Internet Gateways (with tags)
echo -e "\n==== Internet Gateways ===="
awslocal ec2 describe-internet-gateways \
  --query "InternetGateways[].{IGW:InternetGatewayId, VpcId:Attachments[0].VpcId, Tags:Tags}" \
  --output table

# 4. Elastic IPs (with tags)
echo -e "\n==== Elastic IPs (EIPs) ===="
awslocal ec2 describe-addresses \
  --query "Addresses[].{PublicIp:PublicIp, AllocationId:AllocationId, Tags:Tags}" \
  --output table

# 5. NAT Gateways (with AllocationId and tags)
echo -e "\n==== NAT Gateways (with AllocationId) ===="
awslocal ec2 describe-nat-gateways \
  --query "NatGateways[].{NatGatewayId:NatGatewayId, SubnetId:SubnetId, AllocationId:NatGatewayAddresses[0].AllocationId, Tags:Tags}" \
  --output table

echo -e "\n==== Route Tables (non-default VPCs only) ===="
for VPC_ID in $NON_DEFAULT_VPCS; do
  awslocal ec2 describe-route-tables \
    --filters Name=vpc-id,Values=$VPC_ID \
    --query 'RouteTables[].{
      RouteTableId: RouteTableId,
      Associations: Associations[].{Main:Main, SubnetId:SubnetId},
      Routes: Routes[].{Destination:DestinationCidrBlock, GatewayId:GatewayId, NatGatewayId:NatGatewayId}
    }' \
    --output table
done


echo -e "\n✅ Done."

