# TV Shows Management System

A Ruby on Rails application for managing TV shows, episodes, distributors, and user interactions with comprehensive analytics capabilities.

## Table of Contents
- [Setup Instructions](#setup-instructions)
- [Architecture & Design Decisions](#architecture--design-decisions)
- [Database Schema](#database-schema)
- [API Documentation](#api-documentation)
- [Analytics Features](#analytics-features)
- [Testing](#testing)
- [Deployment](#deployment)

## Setup Instructions

### Prerequisites
- Docker and Docker Compose
- Git

### Local Development Setup

1. **Clone the repository**
```bash
git clone <repository-url>
cd looper
```

2. **Build and start the application**
```bash
docker-compose up --build
```

3. **Setup the database**
```bash
docker-compose exec web rails db:create
docker-compose exec web rails db:migrate
docker-compose exec web rails db:seed
```

4. **Run tests**
```bash
docker-compose exec web bundle exec rspec
```

5. **Access the application**
- Application: http://localhost:3000
- Database: PostgreSQL on localhost:5432

### Environment Variables
Create a `.env` file in the root directory:
```env
DATABASE_URL=postgresql://postgres:password@db:5432/looper_development
RAILS_ENV=development
SECRET_KEY_BASE=your_secret_key_here
```

## Architecture & Design Decisions

### Key Assumptions
1. **Multi-tenancy**: Users can have multiple TV shows in their watchlist
2. **Global Distribution**: Distributors operate in different countries with region-specific contracts
3. **Content Hierarchy**: TV Shows → Episodes (seasons are tracked via episode metadata)
4. **Contract Management**: Distribution contracts have start/end dates and exclusivity flags
5. **Analytics Focus**: Heavy emphasis on data analysis and reporting capabilities

### Design Decisions

#### Database Design
- **PostgreSQL**: Chosen for robust relational features, JSON support, and analytical capabilities
- **Normalized Schema**: Separate entities for clear relationships and data integrity
- **Soft Deletes**: Using `active` flags instead of hard deletes for distributors
- **Flexible Associations**: Many-to-many relationships for users-shows and shows-distributors

#### Application Architecture
- **Rails 7**: Latest stable version with modern conventions
- **Service Objects**: Complex business logic extracted to service classes
- **Analytical Models**: Advanced SQL queries implemented as model methods
- **Factory Pattern**: Comprehensive test data generation with FactoryBot

#### API Design
- **RESTful Endpoints**: Standard REST conventions for CRUD operations
- **Nested Resources**: Logical nesting (shows/episodes, distributors/shows)
- **JSON API**: Consistent JSON responses with proper HTTP status codes

## Database Schema

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Users       │    │   TV Shows      │    │  Distributors   │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ id (PK)         │    │ id (PK)         │    │ id (PK)         │
│ email           │    │ title           │    │ name            │
│ name            │    │ genre           │    │ description     │
│ created_at      │    │ release_date    │    │ website_url     │
│ updated_at      │    │ created_at      │    │ country_code    │
└─────────────────┘    │ updated_at      │    │ active          │
         │              └─────────────────┘    │ created_at      │
         │                       │             │ updated_at      │
         │                       │             └─────────────────┘
         │                       │                      │
         │              ┌─────────────────┐             │
         │              │    Episodes     │             │
         │              ├─────────────────┤             │
         │              │ id (PK)         │             │
         │              │ tv_show_id (FK) │             │
         │              │ title           │             │
         │              │ episode_number  │             │
         │              │ season_number   │             │
         │              │ duration        │             │
         │              │ created_at      │             │
         │              │ updated_at      │             │
         │              └─────────────────┘             │
         │                                              │
         │                                              │
┌─────────────────┐              ┌─────────────────────────────┐
│ User TV Shows   │              │   TV Show Distributors      │
├─────────────────┤              ├─────────────────────────────┤
│ id (PK)         │              │ id (PK)                     │
│ user_id (FK)    │              │ tv_show_id (FK)             │
│ tv_show_id (FK) │              │ distributor_id (FK)         │
│ status          │              │ distribution_type           │
│ rating          │              │ region                      │
│ created_at      │              │ contract_start_date         │
│ updated_at      │              │ contract_end_date           │
└─────────────────┘              │ exclusive                   │
                                 │ created_at                  │
                                 │ updated_at                  │
                                 └─────────────────────────────┘

┌─────────────────┐
│ Release Dates   │
├─────────────────┤
│ id (PK)         │
│ tv_show_id (FK) │
│ distributor_id  │
│ release_date    │
│ region          │
│ created_at      │
│ updated_at      │
└─────────────────┘
```

### Relationships
- **Users** ↔ **TV Shows**: Many-to-many through `user_tv_shows`
- **TV Shows** → **Episodes**: One-to-many
- **TV Shows** ↔ **Distributors**: Many-to-many through `tv_show_distributors`
- **TV Shows** → **Release Dates**: One-to-many
- **Distributors** → **Release Dates**: One-to-many (optional)

## Analytics Features

### Advanced SQL Queries
The application includes sophisticated analytical capabilities:

1. **Episode Statistics Analysis**
   - Episode counts and duration analytics
   - Genre-based and overall rankings
   - Uses: CTEs, Window Functions, Aggregates

2. **Distribution Market Analysis**
   - Market share calculations by country
   - Exclusive vs non-exclusive distribution patterns
   - Contract duration analytics

3. **Genre Performance Metrics**
   - Comprehensive genre-level analytics
   - Performance percentiles and rankings
   - Distribution reach analysis

### Usage Examples
```ruby
# Get top shows with episode statistics
TvShow.shows_with_episode_stats.limit(10)

# Analyze distributor market performance
TvShow.distribution_analysis

# Genre performance insights
TvShow.genre_performance_analysis
```

## Testing

### Test Coverage
- **Model Tests**: 27 examples, 0 failures
- **Analytical Tests**: 16 examples covering all SQL queries
- **Factory Tests**: Comprehensive test data generation

### Running Tests
```bash
# All tests
docker-compose exec web bundle exec rspec

# Specific test files
docker-compose exec web bundle exec rspec spec/models/
docker-compose exec web bundle exec rspec spec/models/tv_show_analytical_spec.rb
```

### Test Data
```bash
# Load sample analytical data
docker-compose exec web rails runner "load 'db/seeds_analytical.rb'"
```

## API Documentation

### Core Endpoints
- `GET /tv_shows` - List all TV shows
- `POST /tv_shows` - Create new TV show
- `GET /tv_shows/:id` - Get specific TV show
- `GET /tv_shows/:id/episodes` - Get episodes for a show
- `GET /distributors` - List distributors
- `GET /distributors/:id/tv_shows` - Get shows for distributor

### Analytics Endpoints
- `GET /analytics/episode_stats` - Episode statistics
- `GET /analytics/distribution_analysis` - Distribution metrics
- `GET /analytics/genre_performance` - Genre analytics

## Development

### Code Quality
- RuboCop for style enforcement
- RSpec for testing
- Factory patterns for test data
- Service objects for complex logic

### Database Migrations
```bash
# Create new migration
docker-compose exec web rails generate migration MigrationName

# Run migrations
docker-compose exec web rails db:migrate

# Rollback
docker-compose exec web rails db:rollback
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This project is licensed under the MIT License.
```

## Step 2: Create AWS Deployment Plan

```markdown:docs/aws_deployment_plan.md
# AWS Deployment Plan - TV Shows Management System

## Overview
This document outlines the complete AWS deployment strategy for the TV Shows Management System, including infrastructure, CI/CD, security, and cost considerations.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                          AWS Cloud                              │
│                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐    ┌──────────────┐ │
│  │   CloudFront    │    │      Route53    │    │     WAF      │ │
│  │   (CDN/Cache)   │    │      (DNS)      │    │ (Security)   │ │
│  └─────────────────┘    └─────────────────┘    └──────────────┘ │
│           │                       │                     │       │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                Application Load Balancer                    │ │
│  └─────────────────────────────────────────────────────────────┘ │
│           │                                                     │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                    ECS Fargate Cluster                     │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │ │
│  │  │Rails App    │  │Rails App    │  │   Sidekiq Worker    │ │ │
│  │  │Container 1  │  │Container 2  │  │    Container        │ │ │
│  │  └─────────────┘  └─────────────┘  └─────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────┘ │
│           │                       │                             │
│  ┌─────────────────┐    ┌─────────────────┐                    │
│  │   RDS Postgres  │    │   ElastiCache   │                    │
│  │   (Multi-AZ)    │    │     (Redis)     │                    │
│  └─────────────────┘    └─────────────────┘                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Required AWS Services

### Core Infrastructure

#### 1. **Amazon ECS with Fargate**
- **Purpose**: Container orchestration for Rails application
- **Configuration**:
  - Fargate launch type for serverless containers
  - Auto-scaling based on CPU/memory utilization
  - Service discovery for internal communication
  - Task definitions for Rails app and Sidekiq workers

```yaml
# ecs-task-definition.json
{
  "family": "tv-shows-app",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::ACCOUNT:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::ACCOUNT:role/ecsTaskRole",
  "containerDefinitions": [
    {
      "name": "rails-app",
      "image": "ACCOUNT.dkr.ecr.REGION.amazonaws.com/tv-shows:latest",
      "portMappings": [{"containerPort": 3000}],
      "environment": [
        {"name": "RAILS_ENV", "value": "production"},
        {"name": "DATABASE_URL", "valueFrom": "arn:aws:ssm:REGION:ACCOUNT:parameter/tv-shows/database-url"}
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/tv-shows",
          "awslogs-region": "us-east-1"
        }
      }
    }
  ]
}
```

#### 2. **Amazon RDS PostgreSQL**
- **Purpose**: Primary database for application data
- **Configuration**:
  - Multi-AZ deployment for high availability
  - Read replicas for analytics queries
  - Automated backups with 7-day retention
  - Performance Insights enabled

```yaml
# RDS Configuration
Engine: postgres
Version: 14.9
Instance Class: db.t3.medium (production: db.r5.large)
Storage: 100GB GP2 (production: 500GB GP3)
Multi-AZ: true
Backup Retention: 7 days
Monitoring: Enhanced monitoring enabled
```

#### 3. **Application Load Balancer (ALB)**
- **Purpose**: Load balancing and SSL termination
- **Configuration**:
  - HTTPS listeners with SSL certificates
  - Health checks for ECS services
  - Sticky sessions if needed
  - Integration with AWS WAF

#### 4. **Amazon ElastiCache (Redis)**
- **Purpose**: Session storage, caching, and Sidekiq job queue
- **Configuration**:
  - Redis 7.x cluster mode
  - Multi-AZ with automatic failover
  - Encryption in transit and at rest

### Content Delivery & Security

#### 5. **Amazon CloudFront**
- **Purpose**: CDN for static assets and API caching
- **Configuration**:
  - Origin pointing to ALB
  - Caching policies for static assets
  - Compression enabled
  - Custom error pages

#### 6. **AWS WAF**
- **Purpose**: Web application firewall
- **Configuration**:
  - Rate limiting rules
  - SQL injection protection
  - XSS protection
  - IP whitelist/blacklist capabilities

#### 7. **Route 53**
- **Purpose**: DNS management
- **Configuration**:
  - Hosted zone for domain
  - Health checks for failover
  - Alias records pointing to CloudFront

### Storage & Monitoring

#### 8. **Amazon S3**
- **Purpose**: Static assets, backups, and file uploads
- **Configuration**:
  - Versioning enabled
  - Lifecycle policies for cost optimization
  - Cross-region replication for backups

#### 9. **Amazon ECR**
- **Purpose**: Docker container registry
- **Configuration**:
  - Private repositories
  - Image scanning enabled
  - Lifecycle policies for image cleanup

#### 10. **CloudWatch**
- **Purpose**: Monitoring, logging, and alerting
- **Configuration**:
  - Custom metrics for application performance
  - Log aggregation from ECS containers
  - Alarms for critical metrics
  - Dashboards for monitoring

## CI/CD Pipeline

### GitHub Actions Workflow

````yaml:.github/workflows/deploy.yml
name: Deploy to AWS

on:
  push:
    branches: [main]
  pull_request:
    branches: [