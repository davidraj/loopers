# 🚀 Deployment Guide - TV Shows Management System

## Production Deployment Options

### Option 1: AWS ECS with Fargate (Recommended)

#### Prerequisites
- AWS CLI configured
- Docker installed
- Domain name registered

#### Quick Deploy Commands
```bash
# 1. Create ECR Repository
aws ecr create-repository --repository-name tv-shows-app --region us-east-1

# 2. Build and Push Docker Image
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ACCOUNT.dkr.ecr.us-east-1.amazonaws.com
docker build -t tv-shows-app .
docker tag tv-shows-app:latest ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/tv-shows-app:latest
docker push ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/tv-shows-app:latest

# 3. Create RDS Database
aws rds create-db-instance \
  --db-instance-identifier tv-shows-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username postgres \
  --master-user-password YOUR_SECURE_PASSWORD \
  --allocated-storage 20

# 4. Create ECS Cluster
aws ecs create-cluster --cluster-name tv-shows-cluster --capacity-providers FARGATE
```

#### Environment Variables for Production
```env
RAILS_ENV=production
DATABASE_URL=postgresql://username:password@rds-endpoint:5432/database
REDIS_URL=redis://elasticache-endpoint:6379
SECRET_KEY_BASE=your-64-character-secret-key
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true
```

### Option 2: Heroku (Fastest Deploy)

```bash
# Install Heroku CLI and deploy
heroku create tv-shows-app
heroku addons:create heroku-postgresql:mini
heroku addons:create heroku-redis:mini
heroku config:set RAILS_ENV=production
heroku config:set SECRET_KEY_BASE=$(openssl rand -hex 64)
git push heroku main
heroku run rails db:migrate
heroku run rails db:seed
```

### Option 3: DigitalOcean App Platform

```yaml
# app.yaml
name: tv-shows-app
services:
- name: web
  source_dir: /
  github:
    repo: your-username/tv-shows-app
    branch: main
  run_command: bundle exec rails server -b 0.0.0.0 -p $PORT
  environment_slug: ruby
  instance_count: 1
  instance_size_slug: basic-xxs
databases:
- name: db
  engine: PG
  version: "14"
```

## 🔧 CI/CD Pipeline

```yaml
# .github/workflows/deploy.yml
name: Deploy to Production
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Deploy to Heroku
      uses: akhileshns/heroku-deploy@v3.12.12
      with:
        heroku_api_key: ${{secrets.HEROKU_API_KEY}}
        heroku_app_name: "tv-shows-app"
        heroku_email: "your-email@example.com"
```

## 💰 Cost Estimates (Monthly)
- **Heroku**: $7-25 (Hobby to Standard)
- **DigitalOcean**: $12-24 (Basic to Professional)
- **AWS**: $30-80 (t3.micro to production setup)

## 🔒 Security Checklist
- [ ] Environment variables secured
- [ ] Database password rotated
- [ ] SSL/TLS enabled
- [ ] Security headers configured
- [ ] Rate limiting implemented
- [ ] Backup strategy in place

## 🚨 Troubleshooting
```bash
# Check application logs
heroku logs --tail
# or for Docker
docker-compose logs -f web

# Database connectivity test
rails runner "puts ActiveRecord::Base.connection.active?"

# Redis connectivity test
rails runner "puts Redis.new.ping"
```
EOF
```

## 2. **Create API Documentation with Sample Requests**

```bash
cat > docs/api_endpoints.md << 'EOF'
```

```markdown:docs/api_endpoints.md
# 📡 API Documentation - TV Shows Management System

## 🌐 Base URLs
- **Local Development**: `http://localhost:3000`
- **Production**: `https://your-app-name.herokuapp.com`

## 🔥 Quick Start - Test Your Local Setup

### 1. Start the Application
```bash
docker-compose up --build
docker-compose exec web rails db:create db:migrate db:seed
```

### 2. Verify API is Running
```bash
curl -X GET "http://localhost:3000/health" \
  -H "Content-Type: application/json"
```

## 📺 TV Shows API

### **GET /api/v1/tv_shows** - List All Shows
```bash
# Basic request
curl -X GET "http://localhost:3000/api/v1/tv_shows" \
  -H "Content-Type: application/json"

# With pagination
curl -X GET "http://localhost:3000/api/v1/tv_shows?page=1&per_page=5" \
  -H "Content-Type: application/json"

# Filter by genre
curl -X GET "http://localhost:3000/api/v1/tv_shows?genre=Drama" \
  -H "Content-Type: application/json"
```

**Sample Response:**
```json
{
  "tv_shows": [
    {
      "id": 1,
      "title": "Breaking Bad",
      "genre": "Crime, Drama, Thriller",
      "total_seasons": 5,
      "total_episodes": 62,
      "status": "ended",
      "imdb_rating": 9.5,
      "country_of_origin": "United States",
      "network_name": "AMC"
    }
  ],
  "pagination": {
    "current_page": 1,
    "per_page": 10,
    "total_pages": 1,
    "total_count": 1
  }
}
```

### **GET /api/v1/tv_shows/:id** - Get Specific Show
```bash
curl -X GET "http://localhost:3000/api/v1/tv_shows/1" \
  -H "Content-Type: application/json"
```

### **POST /api/v1/tv_shows** - Create New Show
```bash
curl -X POST "http://localhost:3000/api/v1/tv_shows" \
  -H "Content-Type: application/json" \
  -d '{
    "tv_show": {
      "title": "Stranger Things",
      "description": "Kids uncover supernatural mysteries in 1980s Indiana",
      "genre": "Drama, Fantasy, Horror",
      "total_seasons": 4,
      "total_episodes": 42,
      "status": "running",
      "imdb_rating": 8.7,
      "country_of_origin": "United States",
      "network_name": "Netflix"
    }
  }'
```

### **PUT /api/v1/tv_shows/:id** - Update Show
```bash
curl -X PUT "http://localhost:3000/api/v1/tv_shows/1" \
  -H "Content-Type: application/json" \
  -d '{
    "tv_show": {
      "status": "ended",
      "total_episodes": 65
    }
  }'
```

### **DELETE /api/v1/tv_shows/:id** - Delete Show
```bash
curl -X DELETE "http://localhost:3000/api/v1/tv_shows/1" \
  -H "Content-Type: application/json"
```

## 🎬 Episodes API

### **GET /api/v1/tv_shows/:tv_show_id/episodes** - List Episodes
```bash
curl -X GET "http://localhost:3000/api/v1/tv_shows/1/episodes" \
  -H "Content-Type: application/json"
```

### **POST /api/v1/tv_shows/:tv_show_id/episodes** - Create Episode
```bash
curl -X POST "http://localhost:3000/api/v1/tv_shows/1/episodes" \
  -H "Content-Type: application/json" \
  -d '{
    "episode": {
      "title": "Pilot",
      "episode_number": 1,
      "season_number": 1,
      "duration": 58,
      "summary": "Walter White begins his transformation"
    }
  }'
```

## 🏢 Distributors API

### **GET /api/v1/distributors** - List Distributors
```bash
curl -X GET "http://localhost:3000/api/v1/distributors" \
  -H "Content-Type: application/json"
```

### **GET /api/v1/distributors/:id/tv_shows** - Shows by Distributor
```bash
curl -X GET "http://localhost:3000/api/v1/distributors/1/tv_shows" \
  -H "Content-Type: application/json"
```

## 📊 Analytics API

### **GET /api/v1/analytics/episode_stats** - Episode Statistics
```bash
curl -X GET "http://localhost:3000/api/v1/analytics/episode_stats" \
  -H "Content-Type: application/json"
```

**Sample Response:**
```json
{
  "episode_statistics": [
    {
      "show_title": "Breaking Bad",
      "total_episodes": 62,
      "avg_duration": 47.5,
      "total_duration": 2945,
      "episodes_rank": 1
    }
  ]
}
```

### **GET /api/v1/analytics/distribution_analysis** - Distribution Metrics
```bash
curl -X GET "http://localhost:3000/api/v1/analytics/distribution_analysis" \
  -H "Content-Type: application/json"
```

### **GET /api/v1/analytics/genre_performance** - Genre Analytics
```bash
curl -X GET "http://localhost:3000/api/v1/analytics/genre_performance" \
  -H "Content-Type: application/json"
```

## 👥 Users API

### **GET /api/v1/users/:id/watchlist** - User's Watchlist
```bash
curl -X GET "http://localhost:3000/api/v1/users/1/watchlist" \
  -H "Content-Type: application/json"
```

### **POST /api/v1/users/:id/watchlist** - Add to Watchlist
```bash
curl -X POST "http://localhost:3000/api/v1/users/1/watchlist" \
  -H "Content-Type: application/json" \
  -d '{
    "tv_show_id": 1,
    "status": "watching",
    "rating": 9
  }'
```

## 🔍 Search & Filtering

### **GET /api/v1/search** - Global Search
```bash
# Search shows by title
curl -X GET "http://localhost:3000/api/v1/search?q=breaking&type=tv_shows" \
  -H "Content-Type: application/json"

# Search with multiple filters
curl -X GET "http://localhost:3000/api/v1/tv_shows?genre=Drama&country=United%20States&rating_min=8.0" \
  -H "Content-Type: application/json"
```

## 🚀 Testing Your API

### 1. Health Check
```bash
curl -X GET "http://localhost:3000/health"
# Expected: {"status":"ok","timestamp":"2024-01-01T12:00:00Z"}
```

### 2. Create Test Data
```bash
# Run seeds to populate test data
docker-compose exec web rails db:seed

# Or create analytical test data
docker-compose exec web rails runner "load 'db/seeds_analytical.rb'"
```

### 3. Test Complete Workflow
```bash
# 1. Create a show
SHOW_ID=$(curl -s -X POST "http://localhost:3000/api/v1/tv_shows" \
  -H "Content-Type: application/json" \
  -d '{"tv_show":{"title":"Test Show","genre":"Drama"}}' | jq -r '.id')

# 2. Add an episode
curl -X POST "http://localhost:3000/api/v1/tv_shows/$SHOW_ID/episodes" \
  -H "Content-Type: application/json" \
  -d '{"episode":{"title":"Test Episode","episode_number":1,"season_number":1}}'

# 3. Get analytics
curl -X GET "http://localhost:3000/api/v1/analytics/episode_stats"
```

## 📝 Response Formats

### Success Response (200)
```json
{
  "data": { /* requested data */ },
  "meta": { /* pagination, counts, etc */ }
}
```

### Error Response (4xx/5xx)
```json
{
  "error": {
    "message": "Validation failed",
    "details": ["Title can't be blank"],
    "code": "VALIDATION_ERROR"
  }
}
```

## 🔧 Development Tools

### API Testing with HTTPie
```bash
# Install HTTPie
pip install httpie

# Test endpoints
http GET localhost:3000/api/v1/tv_shows
http POST localhost:3000/api/v1/tv_shows tv_show:='{"title":"New Show","genre":"Comedy"}'
```

### Postman Collection
Import this collection for easy testing:
```json
{
  "info": {"name": "TV Shows API"},
  "item": [
    {
      "name": "Get All Shows",
      "request": {
        "method": "GET",
        "header": [{"key": "Content-Type", "value": "application/json"}],
        "url": {"raw": "{{base_url}}/api/v1/tv_shows"}
      }
    }
  ],
  "variable": [
    {"key": "base_url", "value": "http://localhost:3000"}
  ]
}
```

## 🎯 Rate Limiting
- **Development**: No limits
- **Production**: 1000 requests/hour per IP
- **Headers**: `X-RateLimit-Limit`, `X-RateLimit-Remaining`

## 🔐 Authentication (Future)
Currently no authentication required. For production, consider:
- JWT tokens
- API keys
- OAuth 2.0
EOF
```

## 3. **Update README with Missing API Section**

```bash
cat >> README.md << 'EOF'

## 🌐 Local Endpoint URLs

### Application URLs
- **Main Application**: http://localhost:3000
- **Health Check**: http://localhost:3000/health
- **Database**: Postgre