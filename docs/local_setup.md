# Local Development Setup

## Prerequisites
- Docker Desktop installed and running
- Git
- curl or Postman for API testing

## Quick Start

### 1. Clone and Start Services
```bash
# Clone the repository
git clone <repository-url>
cd looper

# Start all services
docker-compose up --build

# Wait for all services to be healthy (check logs)
docker-compose logs -f web
```

### 2. Setup Database
```bash
# Create and migrate database
docker-compose exec web rails db:create
docker-compose exec web rails db:migrate

# Load sample data
docker-compose exec web rails db:seed
docker-compose exec web rails runner "load 'db/seeds_analytical.rb'"
```

### 3. Verify Installation
```bash
# Check health endpoint
curl http://localhost:3000/health

# Expected response:
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00Z",
  "version": "1.0.0",
  "services": {
    "database": "connected",
    "redis": "connected", 
    "application": "running"
  }
}
```

## Local Endpoints

### Base URL
```
http://localhost:3000
```

### Available Endpoints
- **Health Check**: `GET /health`
- **TV Shows**: `GET /api/v1/tv_shows`
- **Single TV Show**: `GET /api/v1/tv_shows/:id`
- **Create TV Show**: `POST /api/v1/tv_shows`
- **Analytics - Episode Stats**: `GET /api/v1/analytics/episode_stats`
- **Analytics - Distribution**: `GET /api/v1/analytics/distribution_analysis`
- **Analytics - Genre Performance**: `GET /api/v1/analytics/genre_performance`

### Authentication
Currently no authentication required for local development.
Production deployment will include JWT-based authentication.

## Troubleshooting

### Common Issues

1. **Port 3000 already in use**
```bash
# Kill existing Rails processes
sudo lsof -ti:3000 | xargs kill -9

# Or change port in docker-compose.yml
ports:
  - "3001:3000"
```

2. **Database connection issues**
```bash
# Reset database
docker-compose down -v
docker-compose up --build
docker-compose exec web rails db:setup
```

3. **Container build issues**
```bash
# Clean rebuild
docker-compose down
docker system prune -f
docker-compose up --build
```

### Logs
```bash
# View all logs
docker-compose logs

# View specific service logs
docker-compose logs web
docker-compose logs db
docker-compose logs redis
```
```

## Step 5: Sample API Requests and Responses

```bash:docs/api_examples.md
# API Testing Examples

## Health Check

### Request
```bash
curl -X GET http://localhost:3000/health \
  -H "Content-Type: application/json"
```

### Response
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "version": "1.0.0",
  "services": {
    "database": "connected",
    "redis": "connected",
    "application": "running"
  }
}
```

## TV Shows API

### Get All TV Shows

#### Request
```bash
curl -X GET "http://localhost:3000/api/v1/tv_shows?page=1&per_page=5" \
  -H "Content-Type: application/json"
```

#### Response
```json
{
  "data": [
    {
      "id": 1,
      "title": "Stranger Things",
      "genre": "Sci-Fi",
      "release_date": "2021-01-15",
      "episodes_count": 8,
      "distributors": [
        {
          "id": 1,
          "name": "Netflix"
        }
      ],
      "created_at": "2024-01-15T10:00:00.000Z",
      "updated_at": "2024-01-15T10:00:00.000Z"
    }
  ],
  "meta": {
    "page": 1,
    "per_page": 5,
    "total": 15
  }
}
```

### Get Single TV Show

#### Request
```bash
curl -X GET http://localhost:3000/api/v1/tv_shows/1 \
  -H "Content-Type: application/json"
```

#### Response
```json
{
  "data": {
    "id": 1,
    "title": "Stranger Things",
    "genre": "Sci-Fi",
    "release_date": "2021-01-15",
    "episodes_count": 8,
    "distributors": [
      {
        "id": 1,
        "name": "Netflix"
      }
    ],
    "created_at": "2024-01-15T10:00:00.000Z",
    "updated_at": "2024-01-15T10:00:00.000Z"
  }
}
```

### Create TV Show

#### Request
```bash
curl -X POST http://localhost:3000/api/v1/tv_shows \
  -H "Content-Type: application/json" \
  -d '{
    "tv_show": {
      "title": "New Series",
      "genre": "Drama",
      "release_date": "2024-01-01"
    }
  }'
```

#### Response
````json
{
  "data": {
    "id": 16,
    "title": "New Series",
    "