FROM ruby:3.2.8

# Install dependencies
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

# Set working directory
WORKDIR /rails

# Copy application files
COPY . .

# Install gems
RUN bundle install

# Expose port
EXPOSE 3000

# Start command
CMD ["rails", "server", "-b", "0.0.0.0"]
