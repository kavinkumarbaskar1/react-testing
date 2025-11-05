#!/usr/bin/env bash

# Provision Azure Infrastructure using Terraform
set -e

# Placeholder variables
SUBSCRIPTION_ID="<SUBSCRIPTION_ID>"
RESOURCE_GROUP="<RESOURCE_GROUP>"
LOCATION="<LOCATION>"

# Azure Login (assumes environment setup for Service Principal or manual login)
az login
az account set --subscription $SUBSCRIPTION_ID

# Terraform Commands
cd terraform
terraform init
terraform plan -var "resource_group_name=$RESOURCE_GROUP" -var "location=$LOCATION"
terraform apply -auto-approve -var "resource_group_name=$RESOURCE_GROUP" -var "location=$LOCATION"

# Post-provision tasks
RESOURCE_GROUP_ID=$(terraform output resource_group_id)
echo "Azure resources provisioned successfully!"