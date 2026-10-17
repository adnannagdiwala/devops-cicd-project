#!/bin/bash
# ================================================================
# 02 - Create Public Subnet + Route Table
# Run this from AWS CloudShell AFTER 01-create-vpc.sh
# ================================================================

set -e

# Load VPC IDs from previous script
source /tmp/devops-vpc-ids.sh

echo "=========================================="
echo "  Creating Subnet & Route Table"
echo "=========================================="

# Get first available AZ in the region
AZ=$(aws ec2 describe-availability-zones \
    --query 'AvailabilityZones[0].ZoneName' --output text)
echo "Using AZ: $AZ"

# Create Public Subnet
SUBNET_ID=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.1.0/24 \
    --availability-zone $AZ \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=devops-public-subnet},{Key=Project,Value=devops-cicd}]' \
    --query 'Subnet.SubnetId' --output text)
echo "✅ Public Subnet Created: $SUBNET_ID"

# Enable auto-assign public IP on this subnet
aws ec2 modify-subnet-attribute --subnet-id $SUBNET_ID --map-public-ip-on-launch
echo "✅ Auto-assign Public IP enabled"

# Create Route Table
RT_ID=$(aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=devops-public-rt},{Key=Project,Value=devops-cicd}]' \
    --query 'RouteTable.RouteTableId' --output text)
echo "✅ Route Table Created: $RT_ID"

# Add route to Internet Gateway (0.0.0.0/0 → IGW)
aws ec2 create-route \
    --route-table-id $RT_ID \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id $IGW_ID
echo "✅ Default route added to IGW"

# Associate Route Table with Subnet
aws ec2 associate-route-table --route-table-id $RT_ID --subnet-id $SUBNET_ID > /dev/null
echo "✅ Route Table associated with Subnet"

# Save IDs
echo "export SUBNET_ID=$SUBNET_ID" >> /tmp/devops-vpc-ids.sh
echo "export RT_ID=$RT_ID" >> /tmp/devops-vpc-ids.sh

echo ""
echo "=========================================="
echo "  Subnet & Route Table Complete!"
echo "  Subnet ID: $SUBNET_ID"
echo "  Route Table: $RT_ID"
echo "=========================================="
