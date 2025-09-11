#!/bin/bash

# Citizen Sphere Backend Deployment Script for Heroku

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

    APP_NAME="citizen-sphere-backend"
TEAM_NAME="runtimeterror"

echo -e "${GREEN}🚀 Citizen Sphere Backend Deployment to Heroku${NC}"
echo "=============================================="

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

# Add Softtrends MSSQL addon
echo -e "${YELLOW}🗄️  Adding Softtrends MSSQL database...${NC}"
heroku addons:create mssql:micro --app $APP_NAME 2>/dev/null || echo "MSSQL addon might already exist, continuing..."

# Set environment variables
echo -e "${YELLOW}⚙️  Setting environment variables...${NC}"
heroku config:set ASPNETCORE_ENVIRONMENT=Production --app $APP_NAME
heroku config:set JWT_KEY="YourSuperSecretKeyThatIsAtLeast32CharactersLong123456" --app $APP_NAME
heroku config:set JWT_ISSUER="CitizenConcernAPI" --app $APP_NAME
heroku config:set JWT_AUDIENCE="CitizenConcernAPI" --app $APP_NAME
heroku config:set ALLOW_ORIGIN="*" --app $APP_NAME
heroku config:set CORS_ALLOWED_ORIGINS="*" --app $APP_NAME
heroku config:set OpenAI-ApiKey="" --app $APP_NAME

# Set stack to container for Docker deployment
echo -e "${YELLOW}🐳 Setting stack to container...${NC}"
heroku stack:set container --app $APP_NAME

# Navigate to project root (not Backend subdirectory)
cd ..

# Deploy to Heroku using subtree (Backend subdirectory only)
echo -e "${YELLOW}🚢 Deploying to Heroku...${NC}"
git add .
git commit -m "Deploy backend to Heroku" 2>/dev/null || echo "No changes to commit"
heroku git:remote --app $APP_NAME
git subtree push --prefix=Backend heroku main

echo -e "${GREEN}✅ Backend deployment completed!${NC}"
echo -e "${GREEN}🌐 Your API is available at: https://${APP_NAME}.herokuapp.com${NC}"
echo -e "${GREEN}📚 API Documentation: https://${APP_NAME}.herokuapp.com/swagger${NC}"

# Open the app
read -p "Would you like to open the deployed app? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    heroku open --app $APP_NAME
fi