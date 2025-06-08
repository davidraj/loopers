require 'net/http'
require 'json'
require 'uri'

class TvMazeSeeder
  BASE_URL = 'https://api.tvmaze.com'
  
  def initialize
    @created_shows = 0
    @created_distributors = 0
    @created_release_dates = 0
    @created_show_distributors = 0
  end

  def seed_all
    puts "🎬 Starting TVMaze data seeding..."
    
    # Create some default distributors first
    seed_distributors
    
    # Seed shows from TVMaze
    seed_shows
    
    print_summary
  end

  private

  def seed_distributors
    puts "📺 Creating distributors..."
    
    distributors_data = [
      { name: "Netflix", description: "Global streaming platform", website_url: "https://netflix.com", country_code: "US" },
      { name: "HBO Max", description: "Premium streaming service", website_url: "https://hbomax.com", country_code: "US" },
      { name: "Amazon Prime Video", description: "Amazon's streaming service", website_url: "https://primevideo.com", country_code: "US" },
      { name: "Disney+", description: "Disney's streaming platform", website_url: "https://disneyplus.com", country_code: "US" },
      { name: "Hulu", description: "US streaming service", website_url: "https://hulu.com", country_code: "US" },
      { name: "BBC iPlayer", description: "BBC's streaming service", website_url: "https://bbc.co.uk/iplayer", country_code: "GB" },
      { name: "CBC Gem", description: "CBC's streaming platform", website_url: "https://gem.cbc.ca", country_code: "CA" },
      { name: "Stan", description: "Australian streaming service", website_url: "https://stan.com.au", country_code: "AU" }
    ]

    distributors_data.each do |dist_data|
      distributor = Distributor.find_or_create_by(name: dist_data[:name]) do |d|
        d.description = dist_data[:description]
        d.website_url = dist_data[:website_url]
        d.country_code = dist_data[:country_code]
        d.active = true
      end
      @created_distributors += 1 if distributor.persisted?
    end
  end

  def seed_shows
    puts "🎭 Fetching shows from TVMaze..."
    
    # Fetch multiple pages of shows
    (0..4).each do |page|
      puts "  📄 Processing page #{page + 1}/5..."
      shows = fetch_shows_page(page)
      
      shows.each do |show_data|
        process_show(show_data)
        sleep(0.1) # Rate limiting
      end
    end
  end

  def fetch_shows_page(page)
    uri = URI("#{BASE_URL}/shows?page=#{page}")
    response = Net::HTTP.get_response(uri)
    
    if response.code == '200'
      JSON.parse(response.body)
    else
      puts "  ❌ Error fetching page #{page}: #{response.code}"
      []
    end
  rescue => e
    puts "  ❌ Error fetching page #{page}: #{e.message}"
    []
  end

  def process_show(show_data)
    # Map TVMaze data to your schema
    tv_show = TvShow.find_or_create_by(title: show_data['name']) do |show|
      show.description = clean_html(show_data['summary'])
      show.genre = map_genres(show_data['genres'])
      show.status = map_status(show_data['status'])
      show.imdb_rating = show_data.dig('rating', 'average')
      show.language = show_data['language'] || 'en'
      show.runtime_minutes = show_data['runtime']
      show.original_air_date = parse_date(show_data['premiered'])
      show.country_of_origin = map_country(show_data)
    end

    if tv_show.persisted?
      @created_shows += 1
      
      # Create distributor relationships
      create_show_distributors(tv_show, show_data)
      
      # Create release dates
      create_release_dates(tv_show, show_data)
      
      puts "  ✅ Created: #{tv_show.title}"
    end
  rescue => e
    puts "  ❌ Error processing show '#{show_data['name']}': #{e.message}"
  end

  def create_show_distributors(tv_show, show_data)
    # Map network/web channel to distributors
    network_name = show_data.dig('network', 'name')
    web_channel_name = show_data.dig('webChannel', 'name')
    
    [network_name, web_channel_name].compact.each do |dist_name|
      distributor = find_or_create_distributor_from_name(dist_name, show_data)
      
      if distributor
        tv_show_distributor = TvShowDistributor.find_or_create_by(
          tv_show: tv_show,
          distributor: distributor,
          region: map_country(show_data) || 'US'
        ) do |tsd|
          tsd.distribution_type = network_name == dist_name ? 'broadcast' : 'streaming'
          tsd.contract_start_date = parse_date(show_data['premiered'])
          tsd.exclusive = false
        end
        
        @created_show_distributors += 1 if tv_show_distributor.persisted?
      end
    end
  end

  def create_release_dates(tv_show, show_data)
    return unless show_data['premiered']

    # Create release date for show premiere
    release_date = ReleaseDate.find_or_create_by(
      tv_show: tv_show,
      distributor: tv_show.distributors.first,
      release_date: parse_date(show_data['premiered']),
      region: map_country(show_data) || 'US'
    ) do |rd|
      rd.release_type = 'premiere'
      rd.season_number = 1
      rd.notes = "Original air date"
    end

    @created_release_dates += 1 if release_date&.persisted?
  end

  def find_or_create_distributor_from_name(name, show_data)
    return nil unless name

    # Try to find existing distributor first
    distributor = Distributor.find_by("name ILIKE ?", "%#{name}%")
    return distributor if distributor

    # Create new distributor
    country = map_country(show_data) || 'US'
    distributor = Distributor.create(
      name: name,
      description: "TV network/channel",
      country_code: country,
      active: true
    )
    
    @created_distributors += 1 if distributor.persisted?
    distributor
  rescue => e
    puts "    ⚠️  Error creating distributor '#{name}': #{e.message}"
    nil
  end

  # Helper methods for data transformation
  def clean_html(html_string)
    return nil unless html_string
    html_string.gsub(/<[^>]*>/, '').strip
  end

  def map_genres(genres_array)
    return nil unless genres_array&.any?
    genres_array.first # Take the first genre as primary
  end

  def map_status(tvmaze_status)
    case tvmaze_status&.downcase
    when 'running', 'in development'
      'ongoing'
    when 'ended'
      'completed'
    when 'to be determined'
      'upcoming'
    else
      'upcoming'
    end
  end

  def parse_date(date_string)
    return nil unless date_string
    Date.parse(date_string)
  rescue
    nil
  end

  def map_country(show_data)
    # Try network country first, then web channel country
    country = show_data.dig('network', 'country', 'code') ||
              show_data.dig('webChannel', 'country', 'code')
    
    # Ensure it's a 2-character code
    country&.length == 2 ? country : nil
  end

  def print_summary
    puts "\n🎉 Seeding completed!"
    puts "📊 Summary:"
    puts "  • TV Shows: #{@created_shows}"
    puts "  • Distributors: #{@created_distributors}"
    puts "  • Show-Distributor relationships: #{@created_show_distributors}"
    puts "  • Release dates: #{@created_release_dates}"
  end
end

# Clear existing data (optional - remove if you want to keep existing data)
puts "🧹 Clearing existing data..."
ReleaseDate.destroy_all
TvShowDistributor.destroy_all
TvShow.destroy_all
Distributor.destroy_all

# Run the seeder
TvMazeSeeder.new.seed_all

puts "\n✨ Database seeding complete!"
