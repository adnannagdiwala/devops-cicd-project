#!/bin/bash
# ================================================================
# 05 - Launch Jenkins EC2 Instance
# Run this from AWS CloudShell AFTER 04
# ================================================================

set -e

# Load IDs
source /tmp/devops-vpc-ids.sh

echo "=========================================="
echo "  Launching Jenkins EC2 Instance"
echo "=========================================="

# Get latest Ubuntu 22.04 AMI ID for the current region
AMI_ID=$(aws ec2 describe-images \
    --owners 099720109477 \
    --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" \
              "Name=state,Values=available" \
    --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' \
    --output text)
echo "Using AMI: $AMI_ID (Ubuntu 22.04)"

# Launch Jenkins EC2
JENKINS_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t2.medium \
    --key-name $KEY_NAME \
    --subnet-id $SUBNET_ID \
    --security-group-ids $JENKINS_SG_ID \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=devops-jenkins-server},{Key=Project,Value=devops-cicd}]' \
    --query 'Instances[0].InstanceId' --output text)
echo "✅ Jenkins EC2 Launched: $JENKINS_ID"

# Wait for instance to be running
echo "⏳ Waiting for instance to start..."
aws ec2 wait instance-running --instance-ids $JENKINS_ID
echo "✅ Jenkins instance is running!"

# Get public IP
JENKINS_IP=$(aws ec2 describe-instances \
    --instance-ids $JENKINS_ID \
    --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
echo "✅ Jenkins Public IP: $JENKINS_IP"

# Save IDs
echo "export JENKINS_ID=$JENKINS_ID" >> /tmp/devops-vpc-ids.sh
echo "export JENKINS_IP=$JENKINS_IP" >> /tmp/devops-vpc-ids.sh
echo "export AMI_ID=$AMI_ID" >> /tmp/devops-vpc-ids.sh

echo ""
echo "=========================================="
echo "  Jenkins EC2 Ready!"
echo "  Instance ID: $JENKINS_ID"
echo "  Public IP:   $JENKINS_IP"
echo "  SSH: ssh -i ~/devops-project-key.pem ubuntu@$JENKINS_IP"
echo "=========================================="
