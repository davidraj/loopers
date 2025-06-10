puts "🧹 Clearing existing data..."

# Clear dependent records first to avoid foreign key violations
if defined?(Episode)
  Episode.destroy_all
  puts "  - Cleared episodes"
end

TvShow.destroy_all
puts "  - Cleared TV shows"

puts "📺 Creating sample TV shows..."

# Create shows one by one to catch any errors
puts "Creating Breaking Bad..."
TvShow.create!(
  title: "Breaking Bad",
  description: "A high school chemistry teacher diagnosed with inoperable lung cancer turns to manufacturing and selling methamphetamine.",
  genre: "Crime, Drama, Thriller",
  total_seasons: 5,
  total_episodes: 62,
  status: "ended",
  imdb_rating: 9.5,
  language: "en",
  runtime_minutes: 47,
  original_air_date: Date.parse("2008-01-20"),
  country_of_origin: "United States",
  tvmaze_id: 169,
  premiered_at: Date.parse("2008-01-20"),
  network_name: "AMC",
  rating: 0.0
)

puts "Creating Stranger Things..."
TvShow.create!(
  title: "Stranger Things",
  description: "When a young boy vanishes, a small town uncovers a mystery involving secret experiments.",
  genre: "Horror, Sci-Fi, Thriller",
  total_seasons: 4,
  total_episodes: 42,
  status: "ended",
  imdb_rating: 8.7,
  language: "en",
  runtime_minutes: 51,
  original_air_date: Date.parse("2016-07-15"),
  country_of_origin: "United States",
  tvmaze_id: 2993,
  premiered_at: Date.parse("2016-07-15"),
  network_name: "Netflix",
  rating: 0.0
)

puts "Creating The Crown..."
TvShow.create!(
  title: "The Crown",
  description: "This drama follows the political rivalries and romance of Queen Elizabeth II's reign.",
  genre: "Biography, Drama, History",
  total_seasons: 6,
  total_episodes: 60,
  status: "ended",
  imdb_rating: 8.6,
  language: "en",
  runtime_minutes: 58,
  original_air_date: Date.parse("2016-11-04"),
  country_of_origin: "United Kingdom",
  tvmaze_id: 1399,
  premiered_at: Date.parse("2016-11-04"),
  network_name: "Netflix",
  rating: 0.0
)

puts "✅ Created #{TvShow.count} TV shows!"
TvShow.all.each do |show|
  puts "  - #{show.title} (#{show.country_of_origin})"
end
