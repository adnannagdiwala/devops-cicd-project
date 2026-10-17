#!/bin/bash
# ================================================================
# 01 - Create VPC for the DevOps project
# Run this from AWS CloudShell
# ================================================================

set -e  # Exit on any error

echo "=========================================="
echo "  Creating VPC for DevOps CI/CD Project"
echo "=========================================="

# Create VPC
VPC_ID=$(aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=devops-project-vpc},{Key=Project,Value=devops-cicd}]' \
    --query 'Vpc.VpcId' --output text)
echo "✅ VPC Created: $VPC_ID"

# Enable DNS hostnames (required for public DNS)
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames '{"Value":true}'
echo "✅ DNS Hostnames enabled"

# Enable DNS support
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-support '{"Value":true}'
echo "✅ DNS Support enabled"

# Create Internet Gateway
IGW_ID=$(aws ec2 create-internet-gateway \
    --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=devops-igw},{Key=Project,Value=devops-cicd}]' \
    --query 'InternetGateway.InternetGatewayId' --output text)
echo "✅ Internet Gateway Created: $IGW_ID"

# Attach IGW to VPC
aws ec2 attach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
echo "✅ IGW Attached to VPC"

# Save IDs for other scripts
echo "export VPC_ID=$VPC_ID" > /tmp/devops-vpc-ids.sh
echo "export IGW_ID=$IGW_ID" >> /tmp/devops-vpc-ids.sh

echo ""
echo "=========================================="
echo "  VPC Setup Complete!"
echo "  VPC ID:  $VPC_ID"
echo "  IGW ID:  $IGW_ID"
echo "  Saved to: /tmp/devops-vpc-ids.sh"
echo "=========================================="
