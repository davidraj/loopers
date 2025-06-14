puts "🧹 Clearing existing data..."
Episode.destroy_all if defined?(Episode)
TvShow.destroy_all
puts "  - Cleared episodes"
puts "  - Cleared TV shows"

puts "📺 Creating sample TV shows..."

puts "Creating Breaking Bad..."
breaking_bad = TvShow.create!(
  title: "Breaking Bad",
  description: "A high school chemistry teacher diagnosed with inoperable lung cancer turns to manufacturing and selling methamphetamine.",
  genre: "Crime, Drama, Thriller",
  total_seasons: 5,
  total_episodes: 62,
  status: "ended",
  imdb_rating: 9.5,
  language: "en",
  runtime_minutes: 47,
  original_air_date: "2008-01-20",
  country_of_origin: "United States",
  network_name: "AMC",
  tvmaze_id: 169,
  premiered_at: "2008-01-20"
)

puts "Creating The Office..."
the_office = TvShow.create!(
  title: "The Office",
  description: "A mockumentary on a group of typical office workers.",
  genre: "Comedy",
  total_seasons: 9,
  total_episodes: 201,
  status: "ended",
  imdb_rating: 8.7,
  language: "en",
  runtime_minutes: 22,
  original_air_date: "2005-03-24",
  country_of_origin: "United States",
  network_name: "NBC",
  tvmaze_id: 526,
  premiered_at: "2005-03-24"
)

puts "✅ Created #{TvShow.count} TV shows"
puts "🎬 Seeding complete!"
