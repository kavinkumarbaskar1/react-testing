#!/usr/bin/env bash

# Deployment script for react-testing application
set -e

# Placeholder Environment Variables
ENV="<env>"
RESOURCE_GROUP="<resource-group-name>"
APP_NAME="<app-name>"
BRANCH="<branch-name>" # e.g., main
GIT_REPO_URL="<git-repo-url>"

# Cloning Application Repository
git clone $GIT_REPO_URL
cd react-testing
git checkout $BRANCH

# Build Docker Image
docker build -t ${APP_NAME}:${ENV} .

# Deployment into Azure Web App
az webapp deployment source config-zip --resource-group $RESOURCE_GROUP --name $APP_NAME --src ./app.zip

# Log Success Message
echo "Application deployed successfully to Azure!"