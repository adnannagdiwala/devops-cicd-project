#!/bin/bash
# ================================================================
# 03 - Create Security Groups
# Run this from AWS CloudShell AFTER 02-create-subnets.sh
# ================================================================

set -e

# Load IDs
source /tmp/devops-vpc-ids.sh

echo "=========================================="
echo "  Creating Security Groups"
echo "=========================================="

# ── Jenkins Security Group ──
JENKINS_SG_ID=$(aws ec2 create-security-group \
    --group-name devops-jenkins-sg \
    --description "Security group for Jenkins server" \
    --vpc-id $VPC_ID \
    --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=devops-jenkins-sg},{Key=Project,Value=devops-cicd}]' \
    --query 'GroupId' --output text)
echo "✅ Jenkins SG Created: $JENKINS_SG_ID"

# Jenkins: Allow SSH (port 22)
aws ec2 authorize-security-group-ingress --group-id $JENKINS_SG_ID \
    --protocol tcp --port 22 --cidr 0.0.0.0/0
# Jenkins: Allow Jenkins Web UI (port 8080)
aws ec2 authorize-security-group-ingress --group-id $JENKINS_SG_ID \
    --protocol tcp --port 8080 --cidr 0.0.0.0/0
echo "✅ Jenkins SG rules: SSH(22), Jenkins(8080)"

# ── App Server Security Group ──
APP_SG_ID=$(aws ec2 create-security-group \
    --group-name devops-app-sg \
    --description "Security group for App server (Minikube)" \
    --vpc-id $VPC_ID \
    --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=devops-app-sg},{Key=Project,Value=devops-cicd}]' \
    --query 'GroupId' --output text)
echo "✅ App SG Created: $APP_SG_ID"

# App: Allow SSH (port 22)
aws ec2 authorize-security-group-ingress --group-id $APP_SG_ID \
    --protocol tcp --port 22 --cidr 0.0.0.0/0
# App: Allow HTTP (port 80)
aws ec2 authorize-security-group-ingress --group-id $APP_SG_ID \
    --protocol tcp --port 80 --cidr 0.0.0.0/0
# App: Allow NodePort range (30000-32767) for Minikube services
aws ec2 authorize-security-group-ingress --group-id $APP_SG_ID \
    --protocol tcp --port 30000-32767 --cidr 0.0.0.0/0
# App: Allow Grafana (port 3000)
aws ec2 authorize-security-group-ingress --group-id $APP_SG_ID \
    --protocol tcp --port 3000 --cidr 0.0.0.0/0
echo "✅ App SG rules: SSH(22), HTTP(80), NodePort(30000-32767), Grafana(3000)"

# Save IDs
echo "export JENKINS_SG_ID=$JENKINS_SG_ID" >> /tmp/devops-vpc-ids.sh
echo "export APP_SG_ID=$APP_SG_ID" >> /tmp/devops-vpc-ids.sh

echo ""
echo "=========================================="
echo "  Security Groups Complete!"
echo "  Jenkins SG: $JENKINS_SG_ID"
echo "  App SG:     $APP_SG_ID"
echo "=========================================="
