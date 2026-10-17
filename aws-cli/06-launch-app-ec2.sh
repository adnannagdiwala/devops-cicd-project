#!/bin/bash
# ================================================================
# 06 - Launch App Server EC2 Instance (Minikube)
# Run this from AWS CloudShell AFTER 05
# ================================================================

set -e

# Load IDs
source /tmp/devops-vpc-ids.sh

echo "=========================================="
echo "  Launching App Server EC2 (Minikube)"
echo "=========================================="

# Launch App Server EC2 (t2.large for Minikube — needs 2+ CPUs, 4+ GB RAM)
APP_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t2.large \
    --key-name $KEY_NAME \
    --subnet-id $SUBNET_ID \
    --security-group-ids $APP_SG_ID \
    --block-device-mappings '[{"DeviceName":"/dev/sda1","Ebs":{"VolumeSize":30,"VolumeType":"gp3"}}]' \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=devops-app-server},{Key=Project,Value=devops-cicd}]' \
    --query 'Instances[0].InstanceId' --output text)
echo "✅ App Server EC2 Launched: $APP_ID"

# Wait for instance to be running
echo "⏳ Waiting for instance to start..."
aws ec2 wait instance-running --instance-ids $APP_ID
echo "✅ App Server instance is running!"

# Get public IP
APP_IP=$(aws ec2 describe-instances \
    --instance-ids $APP_ID \
    --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
echo "✅ App Server Public IP: $APP_IP"

# Save IDs
echo "export APP_ID=$APP_ID" >> /tmp/devops-vpc-ids.sh
echo "export APP_IP=$APP_IP" >> /tmp/devops-vpc-ids.sh

echo ""
echo "=========================================="
echo "  App Server EC2 Ready!"
echo "  Instance ID: $APP_ID"
echo "  Public IP:   $APP_IP"
echo "  SSH: ssh -i ~/devops-project-key.pem ubuntu@$APP_IP"
echo "=========================================="
echo ""
echo "📋 All Resource IDs saved to /tmp/devops-vpc-ids.sh"
echo "   Run: cat /tmp/devops-vpc-ids.sh"
