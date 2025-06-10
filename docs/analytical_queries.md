# TV Shows Analytical SQL Queries

This document explains the analytical SQL queries implemented for the TV shows application.

## Query 1: TV Shows with Episode Statistics

**Purpose**: Analyze TV shows with episode counts, average durations, and rankings within genres and overall.

**SQL Features Used**:
- Common Table Expressions (CTEs)
- Window Functions (`ROW_NUMBER()`, `RANK()`)
- Aggregates (`COUNT()`, `AVG()`)
- Partitioning (`PARTITION BY`)

**Business Value**:
- Identify most popular shows by episode count
- Compare shows within the same genre
- Understand content volume and episode length patterns

**Key Metrics**:
- Total episodes per show
- Average episode duration
- Genre-specific rankings
- Overall popularity rankings

## Query 2: Distribution Analysis

**Purpose**: Analyze distributor performance, market share, and contract patterns.

**SQL Features Used**:
- Multiple CTEs for complex data transformation
- Conditional aggregation (`CASE WHEN`)
- Percentage calculations
- Date arithmetic for contract duration

**Business Value**:
- Understand distributor market share by country
- Identify exclusive vs non-exclusive distribution patterns
- Analyze contract duration trends
- Support business development decisions

**Key Metrics**:
- Shows distributed per distributor
- Exclusive deals count
- Average contract duration
- Market share percentage by country

## Query 3: Genre Performance Analysis

**Purpose**: Comprehensive genre-level analytics with performance rankings.

**SQL Features Used**:
- CTEs for data aggregation
- Multiple window functions (`ROW_NUMBER()`, `PERCENT_RANK()`)
- Complex joins across multiple tables
- Statistical functions

**Business Value**:
- Identify top-performing genres
- Understand genre distribution patterns
- Support content strategy decisions
- Analyze genre evolution over time

**Key Metrics**:
- Total shows and episodes per genre
- Average episode duration by genre
- Distribution reach per genre
- Genre performance percentiles

## Usage Examples

```ruby
# Get shows with episode statistics
shows_stats = TvShow.shows_with_episode_stats
top_show = shows_stats.first
puts "#{top_show.title} has #{top_show.total_episodes} episodes"

# Analyze distribution patterns
distribution_data = TvShow.distribution_analysis
distribution_data.each do |dist|
  puts "#{dist.distributor_name}: #{dist.market_share_percentage}% market share"
end

# Genre performance analysis
genre_stats = TvShow.genre_performance_analysis
genre_stats.each do |genre|
  puts "#{genre.genre}: Rank ##{genre.shows_rank} with #{genre.total_shows} shows"
end
```
```

## Step 4: Run the tests to make sure everything works

```bash
docker-compose exec web bundle exec rspec spec/models/tv_show_analytical_spec.rb
```

## Step 5: Run all tests to ensure we haven't broken anything

```bash
docker-compose exec web bundle exec rspec spec/models/
```

## Step 6: Create a sample data seeder for testing the analytical queries

```ruby:db/seeds_analytical.rb
# Sample data for testing analytical queries
puts "Creating sample data for analytical queries..."

# Create distributors
netflix = Distributor.create!(
  name: "Netflix",
  country_code: "US",
  description: "Global streaming platform",
  website_url: "https://netflix.com",
  active: true
)

hulu = Distributor.create!(
  name: "Hulu",
  country_code: "US", 
  description: "US streaming service",
  website_url: "https://hulu.com",
  active: true
)

bbc = Distributor.create!(
  name: "BBC iPlayer",
  country_code: "UK",
  description: "British public broadcaster",
  website_url: "https://bbc.co.uk",
  active: true
)

# Create TV shows
shows_data = [
  { title: "Stranger Things", genre: "Sci-Fi", release_date: 3.years.ago, episodes: 8, duration: 50 },
  { title: "The Office", genre: "Comedy", release_date: 5.years.ago, episodes: 22, duration: 22 },
  { title: "Breaking Bad", genre: "Drama", release_date: 4.years.ago, episodes: 13, duration: 47 },
  { title: "Friends", genre: "Comedy", release_date: 10.years.ago, episodes: 24, duration: 22 },
  { title: "Game of Thrones", genre: "Drama", release_date: 6.years.ago, episodes: 10, duration: 55 },
  { title: "Black Mirror", genre: "Sci-Fi", release_date: 2.years.ago, episodes: 6, duration: 60 }
]

shows_data.each do |show_data|
  show = TvShow.create!(
    title: show_data[:title],
    genre: show_data[:genre],
    release_date: show_data[:release_date]
  )
  
  # Create episodes
  show_data[:episodes].times do |i|
    Episode.create!(
      tv_show: show,
      title: "Episode #{i + 1}",
      episode_number: i + 1,
      season_number: 1,
      duration: show_data[:duration] + rand(-5..5) # Add some variation
    )
  end
  
  # Create distribution relationships
  [netflix, hulu, bbc].sample(rand(1..2)).each do |distributor|
    TvShowDistributor.create!(
      tv_show: show,
      distributor: distributor,
      distribution_type: ["streaming", "broadcast", "cable"].sample,
      region: distributor.country_code,
      exclusive: [true, false].sample,
      contract_start_date: rand(2.years.ago..1.year.ago),
      contract_end_date: rand(6.months.from_now..2.years.from_now)
    )
  end
end

puts "Sample data created successfully!"
puts "TV Shows: #{TvShow.count}"
puts "Episodes: #{Episode.count}"
puts "Distributors: #{Distributor.count}"
puts "Distribution relationships: #{TvShowDistributor.count}"
```

Now let's test everything:

```bash
docker-compose exec web bundle exec rspec spec/models/tv_show_analytical_spec.rb
```

After the tests pass, you can commit all the analytical query work:

```bash
git add .
```

```bash
git commit -m "Add analytical SQL queries with CTEs, window functions, and aggregates

- Implement 3 analytical methods in TvShow model:
  * shows_with_episode_stats: Episode statistics with genre/overall rankings
  * distribution_analysis: Market share and distributor performance metrics  
  * genre_performance_analysis: Comprehensive genre analytics with percentiles
- Add comprehensive RSpec tests for all analytical methods
- Create documentation explaining business value and SQL features used
- Add sample data seeder for testing analytical queries
- All queries use advanced SQL features: CTEs, window functions, aggregates"