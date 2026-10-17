#!/bin/bash
# ================================================================
# 07 - Describe all project resources (verify everything)
# Run this from AWS CloudShell anytime
# ================================================================

echo "=========================================="
echo "  DevOps Project — All Resources"
echo "=========================================="

# Load IDs if available
[ -f /tmp/devops-vpc-ids.sh ] && source /tmp/devops-vpc-ids.sh

echo ""
echo "── VPC ──"
aws ec2 describe-vpcs \
    --filters "Name=tag:Project,Values=devops-cicd" \
    --query 'Vpcs[*].{ID:VpcId,CIDR:CidrBlock,State:State}' \
    --output table

echo ""
echo "── Subnets ──"
aws ec2 describe-subnets \
    --filters "Name=tag:Project,Values=devops-cicd" \
    --query 'Subnets[*].{ID:SubnetId,AZ:AvailabilityZone,CIDR:CidrBlock,PublicIP:MapPublicIpOnLaunch}' \
    --output table

echo ""
echo "── Security Groups ──"
aws ec2 describe-security-groups \
    --filters "Name=tag:Project,Values=devops-cicd" \
    --query 'SecurityGroups[*].{ID:GroupId,Name:GroupName}' \
    --output table

echo ""
echo "── EC2 Instances ──"
aws ec2 describe-instances \
    --filters "Name=tag:Project,Values=devops-cicd" "Name=instance-state-name,Values=running,stopped" \
    --query 'Reservations[*].Instances[*].{ID:InstanceId,Name:Tags[?Key==`Name`]|[0].Value,Type:InstanceType,State:State.Name,PublicIP:PublicIpAddress,PrivateIP:PrivateIpAddress}' \
    --output table

echo ""
echo "=========================================="
