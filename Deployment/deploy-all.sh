#!/bin/bash

# Complete Citizen Sphere Deployment Script for Heroku

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🌟 Welcome to Citizen Sphere Complete Deployment${NC}"
echo "=================================================="
echo -e "${BLUE}This script will deploy both backend and frontend to Heroku${NC}"
echo ""

# Check prerequisites
echo -e "${YELLOW}🔍 Checking prerequisites...${NC}"

if ! command -v heroku &> /dev/null; then
    echo -e "${RED}❌ Heroku CLI is not installed. Please install it first.${NC}"
    echo "   Install from: https://devcenter.heroku.com/articles/heroku-cli"
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git is not installed. Please install it first.${NC}"
    exit 1
fi

if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed. Please install it first.${NC}"
    exit 1
fi

if ! command -v dotnet &> /dev/null; then
    echo -e "${RED}❌ .NET Core SDK is not installed. Please install it first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ All prerequisites are installed${NC}"

# Check if already logged into Heroku
echo -e "${YELLOW}📝 Checking Heroku authentication...${NC}"
if ! heroku auth:whoami &> /dev/null; then
    echo -e "${YELLOW}🔐 Not logged in. Please login to Heroku...${NC}"
    heroku auth:login
else
    echo -e "${GREEN}✅ Already logged in as: $(heroku auth:whoami)${NC}"
fi

echo ""
echo -e "${BLUE}🚀 Starting deployment process...${NC}"
echo ""

# Deploy Backend
echo -e "${YELLOW}============ DEPLOYING BACKEND ============${NC}"
./deploy-backend.sh

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Backend deployment successful${NC}"
else
    echo -e "${RED}❌ Backend deployment failed${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}============ DEPLOYING FRONTEND ============${NC}"
# Deploy Frontend
./deploy-frontend.sh

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Frontend deployment successful${NC}"
else
    echo -e "${RED}❌ Frontend deployment failed${NC}"
    exit 1
fi

#post deployment steps
./post-deploy.sh

echo ""
echo -e "${GREEN}🎉 DEPLOYMENT COMPLETED SUCCESSFULLY! 🎉${NC}"
echo "=========================================="
echo -e "${GREEN}🌐 Frontend: https://citizen-sphere-frontend.herokuapp.com${NC}"
echo -e "${GREEN}🔧 Backend API: https://citizen-sphere-backend.herokuapp.com${NC}"
echo -e "${GREEN}📚 API Docs: https://citizen-sphere-backend.herokuapp.com/swagger${NC}"
echo ""
echo -e "${BLUE}📋 Demo Credentials:${NC}"
echo -e "${YELLOW}   • Super Admin: superadmin@government.local / SuperAdmin@123${NC}"
echo -e "${YELLOW}   • Admin: admin1@government.local / Admin@123${NC}"
echo -e "${YELLOW}   • Officer: officer1@government.local / Officer@123${NC}"
echo -e "${YELLOW}   • Citizen: citizen1@test.com / Citizen@123${NC}"
echo ""
echo -e "${BLUE}🔧 Useful Heroku Commands (Team: runtimeterror):${NC}"
echo -e "${YELLOW}   • View backend logs: heroku logs --tail --app citizen-sphere-backend${NC}"
echo -e "${YELLOW}   • View frontend logs: heroku logs --tail --app citizen-sphere-frontend${NC}"
echo -e "${YELLOW}   • Open backend: heroku open --app citizen-sphere-backend${NC}"
echo -e "${YELLOW}   • Open frontend: heroku open --app citizen-sphere-frontend${NC}"
echo -e "${YELLOW}   • Team dashboard: heroku teams:info runtimeterror${NC}"