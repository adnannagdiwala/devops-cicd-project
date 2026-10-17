#!/bin/bash
# ================================================================
# 04 - Create Key Pair for SSH access
# Run this from AWS CloudShell AFTER 03
# ================================================================

set -e

echo "=========================================="
echo "  Creating SSH Key Pair"
echo "=========================================="

KEY_NAME="devops-project-key"

# Create key pair and save private key
aws ec2 create-key-pair \
    --key-name $KEY_NAME \
    --key-type rsa \
    --query 'KeyMaterial' --output text > ~/devops-project-key.pem

# Set correct permissions
chmod 400 ~/devops-project-key.pem

echo "✅ Key Pair Created: $KEY_NAME"
echo "✅ Private key saved to: ~/devops-project-key.pem"

# Save key name
echo "export KEY_NAME=$KEY_NAME" >> /tmp/devops-vpc-ids.sh

echo ""
echo "=========================================="
echo "  Key Pair Complete!"
echo "  IMPORTANT: Download ~/devops-project-key.pem"
echo "  from CloudShell before it expires!"
echo "=========================================="
