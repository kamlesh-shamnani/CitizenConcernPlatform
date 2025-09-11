#!/bin/bash

# Citizen Sphere Frontend Deployment Script for Heroku

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

APP_NAME="citizen-sphere-frontend"
TEAM_NAME="runtimeterror"
BACKEND_URL="https://citizen-sphere-backend.herokuapp.com" #This is not working, replace original hosted API URL with new value in environment.prod.ts

echo -e "${GREEN}🚀 Citizen Sphere Frontend Deployment to Heroku${NC}"
echo "==============================================="

# Check if Heroku CLI is installed
if ! command -v heroku &> /dev/null; then
    echo -e "${RED}❌ Heroku CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if already logged into Heroku
echo -e "${YELLOW}📝 Checking Heroku authentication...${NC}"
if ! heroku auth:whoami &> /dev/null; then
    echo -e "${YELLOW}🔐 Not logged in. Please login to Heroku...${NC}"
    heroku auth:login
else
    echo -e "${GREEN}✅ Already logged in as: $(heroku auth:whoami)${NC}"
fi

# Create Heroku app
echo -e "${YELLOW}🏗️  Creating Heroku app: ${APP_NAME}${NC}"
heroku create $APP_NAME --region eu --team $TEAM_NAME 2>/dev/null || echo "App might already exist, continuing..."

# Set environment variables
echo -e "${YELLOW}⚙️  Setting environment variables...${NC}"
heroku config:set NODE_ENV=production --app $APP_NAME

# Set stack to container for Docker deployment
echo -e "${YELLOW}🐳 Setting stack to container...${NC}"
heroku stack:set container --app $APP_NAME

# Navigate to project root
cd ..

# Update environment files to use configurable API URL
echo -e "${YELLOW}🔧 Updating environment configuration...${NC}"
cat > Frontend/src/environments/environment.prod.ts << EOL
export const environment = {
  production: true,
  apiUrl: '$BACKEND_URL/api'
};
EOL

# Deploy to Heroku using subtree (Frontend subdirectory only)
echo -e "${YELLOW}🚢 Deploying to Heroku...${NC}"
git add .
git commit -m "Deploy frontend to Heroku" 2>/dev/null || echo "No changes to commit"
heroku git:remote --app $APP_NAME
git subtree push --prefix=Frontend heroku main

echo -e "${GREEN}✅ Frontend deployment completed!${NC}"
echo -e "${GREEN}🌐 Your app is available at: https://${APP_NAME}.herokuapp.com${NC}"

# Open the app
read -p "Would you like to open the deployed app? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    heroku open --app $APP_NAME
fi