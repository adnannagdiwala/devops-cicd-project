#!/bin/bash
# ================================================================
# 99 - CLEANUP: Destroy ALL project resources
# ⚠️  Run this after every demo to avoid AWS charges!
# Run this from AWS CloudShell
# ================================================================

echo "⚠️  =========================================="
echo "⚠️  WARNING: This will DESTROY all resources!"
echo "⚠️  =========================================="
echo ""
read -p "Are you sure? Type 'yes' to confirm: " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "❌ Aborted."
    exit 0
fi

# Load IDs
source /tmp/devops-vpc-ids.sh 2>/dev/null

echo ""
echo "── Step 1: Terminate EC2 Instances ──"
INSTANCE_IDS=$(aws ec2 describe-instances \
    --filters "Name=tag:Project,Values=devops-cicd" "Name=instance-state-name,Values=running,stopped" \
    --query 'Reservations[*].Instances[*].InstanceId' --output text)

if [ -n "$INSTANCE_IDS" ]; then
    aws ec2 terminate-instances --instance-ids $INSTANCE_IDS
    echo "⏳ Waiting for instances to terminate..."
    aws ec2 wait instance-terminated --instance-ids $INSTANCE_IDS
    echo "✅ Instances terminated"
else
    echo "No instances found"
fi

echo ""
echo "── Step 2: Delete Key Pair ──"
aws ec2 delete-key-pair --key-name devops-project-key 2>/dev/null && echo "✅ Key pair deleted" || echo "No key pair found"
rm -f ~/devops-project-key.pem

echo ""
echo "── Step 3: Delete Security Groups ──"
for SG_ID in $(aws ec2 describe-security-groups \
    --filters "Name=tag:Project,Values=devops-cicd" \
    --query 'SecurityGroups[*].GroupId' --output text); do
    aws ec2 delete-security-group --group-id $SG_ID 2>/dev/null && echo "✅ Deleted SG: $SG_ID"
done

echo ""
echo "── Step 4: Delete Subnet ──"
for SUBNET in $(aws ec2 describe-subnets \
    --filters "Name=tag:Project,Values=devops-cicd" \
    --query 'Subnets[*].SubnetId' --output text); do
    aws ec2 delete-subnet --subnet-id $SUBNET 2>/dev/null && echo "✅ Deleted Subnet: $SUBNET"
done

echo ""
echo "── Step 5: Delete Route Table ──"
for RT in $(aws ec2 describe-route-tables \
    --filters "Name=tag:Project,Values=devops-cicd" \
    --query 'RouteTables[*].RouteTableId' --output text); do
    # Disassociate first
    for ASSOC in $(aws ec2 describe-route-tables --route-table-ids $RT \
        --query 'RouteTables[0].Associations[?!Main].RouteTableAssociationId' --output text); do
        aws ec2 disassociate-route-table --association-id $ASSOC 2>/dev/null
    done
    aws ec2 delete-route-table --route-table-id $RT 2>/dev/null && echo "✅ Deleted RT: $RT"
done

echo ""
echo "── Step 6: Detach & Delete Internet Gateway ──"
VPC_ID=$(aws ec2 describe-vpcs \
    --filters "Name=tag:Project,Values=devops-cicd" \
    --query 'Vpcs[0].VpcId' --output text)

if [ "$VPC_ID" != "None" ] && [ -n "$VPC_ID" ]; then
    for IGW in $(aws ec2 describe-internet-gateways \
        --filters "Name=attachment.vpc-id,Values=$VPC_ID" \
        --query 'InternetGateways[*].InternetGatewayId' --output text); do
        aws ec2 detach-internet-gateway --internet-gateway-id $IGW --vpc-id $VPC_ID 2>/dev/null
        aws ec2 delete-internet-gateway --internet-gateway-id $IGW 2>/dev/null && echo "✅ Deleted IGW: $IGW"
    done
fi

echo ""
echo "── Step 7: Delete VPC ──"
if [ "$VPC_ID" != "None" ] && [ -n "$VPC_ID" ]; then
    aws ec2 delete-vpc --vpc-id $VPC_ID 2>/dev/null && echo "✅ Deleted VPC: $VPC_ID"
fi

# Clean up local files
rm -f /tmp/devops-vpc-ids.sh

echo ""
echo "=========================================="
echo "  ✅ ALL resources cleaned up!"
echo "=========================================="
