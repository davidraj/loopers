# Looper

A modern Rails application built with Docker, PostgreSQL, and comprehensive testing setup.

## Features

- **Rails 7.1** - Latest Rails framework
- **PostgreSQL** - Robust database system
- **Docker & Docker Compose** - Containerized development environment
- **RSpec** - Behavior-driven testing framework
- **Factory Bot** - Test data generation
- **Database Cleaner** - Clean test database state
- **Shoulda Matchers** - Rails-specific RSpec matchers
- **RuboCop** - Ruby code style checker

## Prerequisites

- Docker
- Docker Compose
- Git

## Quick Start

### 1. Clone and Setup

```bash
git clone <your-repo-url>
cd looper
```

### 2. Build and Start Services

```bash
# Build the Docker images
docker-compose build

# Start the database
docker-compose up -d db

# Create and migrate databases
docker-compose run --user root web bash -c 'cd /myapp && bundle exec rails db:create'
docker-compose run --user root web bash -c 'cd /myapp && bundle exec rails db:migrate'
docker-compose run --user root web bash -c 'cd /myapp && bundle exec rails db:migrate RAILS_ENV=test'
```

### 3. Start the Application

```bash
# Start all services
docker-compose up

# Or run in background
docker-compose up -d
```

Visit: http://localhost:3000

## Development Commands

### Database Operations

```bash
# Create databases
docker-compose run --user root web bash -c 'cd /myapp && bundle exec rails db:create'

# Run migrations
docker-compose run --user root web bash -c 'cd /myapp && bundle exec rails db:migrate'

# Rollback migration
docker-compose run --user root web bash -c 'cd /myapp && bundle exec rails db:rollback'

# Reset database
docker-compose run --user root web bash -c 'cd /myapp && bundle exec rails db:reset'
```

### Testing

```bash
# Run all tests
docker-compose run --user root web bash -c 'cd /myapp && bundle exec rspec'

# Run specific test file
docker-compose run --user root web bash -c 'cd /myapp && bundle exec rspec spec/models/user_spec.rb'

# Run tests with documentation format
docker-compose run --user root web bash -c 'cd /myapp && bundle exec rspec --format documentation'
```

### Code Quality

```bash
# Run RuboCop
docker-compose run --user root web bash -c 'cd /myapp && bundle exec rubocop'

# Auto-fix RuboCop issues
docker-compose run --user root web bash -c 'cd /myapp && bundle exec rubocop -a'
```

### Rails Console

```bash
# Open Rails console
docker-compose run --user root web bash -c 'cd /myapp && bundle exec rails console'
```

### Generate Code

```bash
# Generate model
docker-compose run --user root web bash -c 'cd /myapp && bundle exec rails generate model User name:string email:string'

# Generate controller
docker-compose run --user root web bash -c 'cd /myapp && bundle exec rails generate controller Users index show'

# Generate migration
docker-compose run --user root web bash -c 'cd /myapp && bundle exec rails generate migration AddAgeToUsers age:integer'
```

## Project Structure

```
looper/
├── app/                    # Application code
│   ├── controllers/        # Controllers
│   ├── models/            # Models
│   ├── views/             # Views
│   └── ...
├── config/                # Configuration files
├── db/                    # Database files
├── spec/                  # RSpec tests
│   ├── models/            # Model tests
│   ├── controllers/       # Controller tests
│   ├── rails_helper.rb    # Rails-specific test config
│   └── spec_helper.rb     # General RSpec config
├── docker-compose.yml     # Docker services configuration
├── Dockerfile            # Docker image configuration
├── Gemfile               # Ruby dependencies
└── README.md            # This file
```

## Database Configuration

- **Development**: PostgreSQL on port 5433 (mapped from container port 5432)
- **Test**: Separate PostgreSQL database for testing
- **Production**: Configured for deployment (update as needed)

## Environment Variables

Key environment variables used:

- `DATABASE_HOST=db`
- `DATABASE_USERNAME=postgres`
- `DATABASE_PASSWORD=password`
- `DATABASE_PORT=5432`
- `RAILS_ENV=development`

## Testing Strategy

- **RSpec** for behavior-driven testing
- **Factory Bot** for creating test data
- **Database Cleaner** for maintaining clean test state
- **Shoulda Matchers** for Rails-specific assertions

### Test Types

- **Model tests**: `spec/models/`
- **Controller tests**: `spec/controllers/`
- **Request tests**: `spec/requests/`
- **Feature tests**: `spec/features/`

## Troubleshooting

### Common Issues

1. **Permission Denied**: Use `--user root` flag with docker-compose run
2. **Database Connection**: Ensure database service is running
3. **Port Conflicts**: Database runs on port 5433 to avoid conflicts

### Useful Commands

```bash
# View logs
docker-compose logs web
docker-compose logs db

# Restart services
docker-compose restart

# Clean up
docker-compose down --remove-orphans
docker-compose down -v  # Remove volumes too

# Rebuild from scratch
docker-compose down -v
docker-compose build --no-cache
docker-compose up
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for your changes
4. Ensure all tests pass
5. Submit a pull request

## License

This project is licensed under the MIT License.
```

##  17: Create a sample model and test

Let's create a User model as an example:

```bash
docker-compose run --user root web bash -c 'cd /myapp && bundle exec rails generate model User name:string email:string age:integer'
```

```bash
docker-compose run --user root web bash -c 'cd /myapp && bundle exec rails db:migrate'
```

##  18: Create a comprehensive User model test

```bash
docker-compose run --user root web bash -c 'cd /myapp && cat > spec/models/user_spec.rb << "EOF"
require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      user = User.new(name: "John Doe", email: "john@example.com", age: 25)
      expect(user).to be_valid
    end
  end

  describe "attributes" do
    it "has a name" do
      user = User.new(name: "John Doe")
      expect(user.name).to eq("John Doe")
    end

    it "has an email" do
      user = User.new(email: "john@example.com")
      expect(user.email).to eq("john@example.com")
    end

    it "has an age" do
      user = User.new(age: 25)
      expect(user.age).to eq(25)
    end
  end
end
EOF'
```

##  19: Run the complete test suite

```bash
docker-compose run --user root web bash -c 'cd /myapp && bundle exec rspec --format documentation'
```

##  20: Create a basic controller

```bash
docker-compose run --user root web bash -c 'cd /myapp && bundle exec rails generate controller Users index show'
```

##  21: Start the application

```bash
docker-compose up
```

## Database Setup

### Initial Setup
```bash
# Create and migrate the database
docker-compose exec web bundle exec rails db:create
docker-compose exec web bundle exec rails db:migrate
```

### **Required: Seed the Database**

⚠️ **Important:** This project requires seeding the database with TVMaze data to function properly. The application expects TV shows, distributors, and their relationships to be present.

#### Seed with TVMaze Data (Required)
```bash
# This command is REQUIRED to populate the database with all necessary data
docker-compose exec web bundle exec rake tvmaze:seed
```

**This command will populate your database with:**
- **~2,500 TV Shows** from TVMaze API (title, description, genre, ratings, etc.)
- **Major Distributors** (Netflix, HBO Max, Amazon Prime Video, Disney+, Hulu, BBC iPlayer, etc.)
- **Show-Distributor Relationships** (which shows are on which platforms)
- **Release Dates** (premiere dates and regional releases)

**⏱️ Note:** The seeding process takes several minutes due to API rate limiting. You'll see progress indicators during the process.

#### Verify Seeding Worked
```bash
# Check that data was imported successfully
docker-compose exec web bundle exec rails runner "puts 'TV Shows: #{TvShow.count}, Distributors: #{Distributor.count}'"
```

You should see output like: `TV Shows: 2487, Distributors: 156`

#### Alternative Seeding Options (Optional)
```bash
# If you only want distributors without TV shows
docker-compose exec web bundle exec rake tvmaze:seed_distributors
```
