#!/bin/bash

# Color definitions for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

API_APP_NAME="citizen-sphere-backend"

echo -e "${GREEN}🚀 Starting post-deployment configuration...${NC}"

# Retrieve MSSQL_TCP_URL from Heroku config
echo -e "${YELLOW}🔍 Retrieving MSSQL_TCP_URL from Heroku config...${NC}"

# Save connection string to temporary file to handle special characters
heroku config:get MSSQL_TCP_URL --app $API_APP_NAME > temp_conn_string.txt

if [ $? -eq 0 ] && [ -s temp_conn_string.txt ]; then
    echo -e "${GREEN}✅ Retrieved MSSQL_TCP_URL from Heroku config${NC}"
    
    echo -e "${YELLOW}⚙️  Setting ConnectionStrings__DefaultConnection environment variable...${NC}"
    
    # Use PowerShell on Windows to handle special characters properly
    if command -v powershell.exe >/dev/null 2>&1; then
        echo -e "${YELLOW}📝 Using PowerShell to handle special characters in connection string...${NC}"
        CONN_STRING=$(cat temp_conn_string.txt | tr -d '\n')
        powershell.exe -c "heroku config:set 'ConnectionStrings__DefaultConnection=${CONN_STRING}' --app $API_APP_NAME"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Successfully set ConnectionStrings__DefaultConnection${NC}"
        else
            echo -e "${RED}❌ Failed to set ConnectionStrings__DefaultConnection${NC}"
            exit 1
        fi
    else
        # Fallback for non-Windows environments
        echo -e "${YELLOW}📝 Using bash to set connection string...${NC}"
        CONN_STRING=$(cat temp_conn_string.txt | tr -d '\n')
        heroku config:set "ConnectionStrings__DefaultConnection=${CONN_STRING}" --app $API_APP_NAME
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Successfully set ConnectionStrings__DefaultConnection${NC}"
        else
            echo -e "${RED}❌ Failed to set ConnectionStrings__DefaultConnection${NC}"
            exit 1
        fi
    fi
    
    # Clean up temporary file
    rm -f temp_conn_string.txt
    
    echo -e "${GREEN}🎉 Post-deployment configuration completed successfully!${NC}"
    echo -e "${YELLOW}📋 Verifying configuration...${NC}"
    
    # Verify the configuration was set correctly
    heroku config:get ConnectionStrings__DefaultConnection --app $API_APP_NAME >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Configuration verified successfully${NC}"
    else
        echo -e "${RED}❌ Configuration verification failed${NC}"
        exit 1
    fi
    
else
    echo -e "${RED}❌ Failed to retrieve MSSQL_TCP_URL from Heroku config${NC}"
    rm -f temp_conn_string.txt
    exit 1
fi