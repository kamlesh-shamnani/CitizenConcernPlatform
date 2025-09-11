# 🚀 Citizen Sphere Heroku Deployment Guide

This guide will help you deploy your **Citizen Sphere** platform (backend API, frontend PWA, and database) to Heroku for production use.

## 📋 Prerequisites

Before starting, ensure you have the following installed:

- **Heroku CLI**: [Download here](https://devcenter.heroku.com/articles/heroku-cli)
- **Git**: [Download here](https://git-scm.com/)
- **Node.js 18+**: [Download here](https://nodejs.org/)
- **NET Core 8.0 SDK**: [Download here](https://dotnet.microsoft.com/download)

## 🏗️ Deployment Architecture

Your Citizen Sphere platform will be deployed as:

```
┌────────────────────────────────────────────────┐
│                   HEROKU CLOUD                 │
├────────────────────────────────────────────────┤
│  Frontend (Angular PWA)                        │
│  └── citizen-sphere-frontend.herokuapp.com     │
├────────────────────────────────────────────────┤
│  Backend (.NET Core API)                       │
│  └── citizen-sphere-backend.herokuapp.com      │
├────────────────────────────────────────────────┤
│  Database (Softtrends MSSQL)                   │
│  └── Softtrends MSSQL Micro                    │
└────────────────────────────────────────────────┘
```

## 🎯 Quick Deployment (Recommended)

### Option 1: Deploy Everything at Once

```bash
# Make scripts executable
chmod +x deploy-all.sh deploy-backend.sh deploy-frontend.sh post-deploy.sh

# Run complete deployment
./deploy-all.sh
```

### Option 2: Deploy Individually

#### Deploy Backend First:

```bash
chmod +x deploy-backend.sh
./deploy-backend.sh
```

#### Then Deploy Frontend:

```bash
chmod +x deploy-frontend.sh
./deploy-frontend.sh
```

## 🔧 Manual Deployment Steps

### 1. Backend Deployment

```bash
# Navigate to your project root
cd CitizenConcernPlatform

# Login to Heroku
heroku login

# Create backend app (using team: runtimeterror)
heroku create citizen-sphere-backend --region eu --team runtimeterror

# Add Softtrends MSSQL database
heroku addons:create mssql:micro --app citizen-sphere-backend

# Set environment variables
heroku config:set ASPNETCORE_ENVIRONMENT=Production --app citizen-sphere-backend
heroku config:set JWT_KEY="YourSuperSecretKeyThatIsAtLeast32CharactersLong123456" --app citizen-sphere-backend
heroku config:set JWT_ISSUER="CitizenConcernAPI" --app citizen-sphere-backend
heroku config:set JWT_AUDIENCE="CitizenConcernAPI" --app citizen-sphere-backend

# Set stack to container
heroku stack:set container --app citizen-sphere-backend

# Deploy backend
cd Backend
git init
git add .
git commit -m "Initial backend deployment"
heroku git:remote --app citizen-sphere-backend
git push heroku main
```

### 2. Frontend Deployment

```bash
# Navigate back to project root
cd ..

# Create frontend app (using team: runtimeterror)
heroku create citizen-sphere-frontend --region eu --team runtimeterror

# Set environment variables
heroku config:set NODE_ENV=production --app citizen-sphere-frontend

# Set stack to container
heroku stack:set container --app citizen-sphere-frontend

# Update environment configuration
cd Frontend
cat > src/environments/environment.prod.ts << EOL
export const environment = {
  production: true,
  apiUrl: 'https://citizen-sphere-backend.herokuapp.com/api'
};
EOL

# Deploy frontend
git init
git add .
git commit -m "Initial frontend deployment"
heroku git:remote --app citizen-sphere-frontend
git push heroku main
```

## 🔗 Your Deployed Applications

After successful deployment, your applications will be available at:

- **🌐 Frontend PWA**: https://citizen-sphere-frontend.herokuapp.com
- **🔧 Backend API**: https://citizen-sphere-backend.herokuapp.com
- **📚 API Documentation**: https://citizen-sphere-backend.herokuapp.com/swagger

## 👥 Demo Accounts

Your deployed application comes with pre-seeded demo accounts:

| Role        | Email                       | Password       |
| ----------- | --------------------------- | -------------- |
| Super Admin | superadmin@government.local | SuperAdmin@123 |
| Admin       | admin1@government.local     | Admin@123      |
| Officer     | officer1@government.local   | Officer@123    |
| Citizen     | citizen1@test.com           | Citizen@123    |

## 🔧 Post-Deployment Management

### Team Management

```bash
# View team info
heroku teams:info runtimeterror

# View team apps
heroku apps --team runtimeterror
```

### View Logs

```bash
# Backend logs
heroku logs --tail --app citizen-sphere-backend

# Frontend logs
heroku logs --tail --app citizen-sphere-frontend
```

### Environment Variables

```bash
# View all config vars
heroku config --app citizen-sphere-backend
heroku config --app citizen-sphere-frontend

# Set a new environment variable
heroku config:set VARIABLE_NAME=value --app APP_NAME
```

### Database Management

```bash
# View addon details
heroku addons:info mssql --app citizen-sphere-backend

# Access database connection info
heroku config:get DATABASE_URL --app citizen-sphere-backend

# Note: Database access is through Azure SQL Database tools
# Use SQL Server Management Studio or Azure Data Studio for direct access
# Backups are managed automatically by Azure SQL
```

### Scaling

```bash
# Scale up dynos
heroku ps:scale web=2 --app citizen-sphere-backend

# View current dyno usage
heroku ps --app citizen-sphere-backend
```

## 🚨 Troubleshooting

### Common Issues

1. **Build Failures**

   ```bash
   # Check build logs
   heroku logs --app APP_NAME

   # Rebuild
   heroku builds:create --app APP_NAME
   ```

2. **Database Connection Issues**

   ```bash
   # Check database URL
   heroku config:get DATABASE_URL --app citizen-sphere-backend
   ```

3. **Environment Variable Issues**
   ```bash
   # Check all environment variables
   heroku config --app APP_NAME
   ```

### Performance Monitoring

```bash
# View app metrics
heroku logs --tail --app citizen-sphere-backend | grep "ms"

# Check dyno usage
heroku ps --app citizen-sphere-backend
```

## 💰 Pricing Information

### Free Tier Limitations (Heroku)

- **Dynos**: Sleep after 30 minutes of inactivity
- **Database**: 10,000 rows limit
- **Build Time**: 15 minutes max

### Production Recommendations

- **Backend**: Hobby dyno ($7/month)
- **Frontend**: Hobby dyno ($7/month)
- **Database**: Essential-0 ($5/month)

**Total Monthly Cost: ~$19/month**

## 📧 Custom Domain Setup

```bash
# Add custom domain
heroku domains:add yourdomain.com --app citizen-sphere-frontend

# Get DNS target
heroku domains --app citizen-sphere-frontend

# Update DNS records at your domain provider
# CNAME: www -> your-app-name.herokuapp.com
```

## 🔄 CI/CD Pipeline Setup

For automated deployments, connect your GitHub repository:

1. Go to Heroku Dashboard
2. Select your app
3. Go to Deploy tab
4. Connect to GitHub
5. Enable Automatic Deploys

## ✅ Deployment Checklist

- [ ] Prerequisites installed
- [ ] Heroku CLI logged in
- [ ] Environment variables set
- [ ] Database added and configured
- [ ] Both apps deployed successfully
- [ ] Frontend connects to backend
- [ ] Demo accounts working
- [ ] SSL certificates active
- [ ] Logs monitoring setup

---

## 🎉 Congratulations!

Your **Citizen Sphere** platform is now live on Heroku! 🚀

For support or questions, check the project documentation or create an issue in the repository.

**Happy deploying!** 🌟
