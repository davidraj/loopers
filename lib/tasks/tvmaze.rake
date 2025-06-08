namespace :tvmaze do
  desc "Seed database with TVMaze data"
  task seed: :environment do
    load Rails.root.join('db', 'seeds.rb')
  end

  desc "Seed only distributors"
  task seed_distributors: :environment do
    puts "📺 Creating distributors..."
    
    distributors_data = [
      { name: "Netflix", description: "Global streaming platform", website_url: "https://netflix.com", country_code: "US" },
      { name: "HBO Max", description: "Premium streaming service", website_url: "https://hbomax.com", country_code: "US" },
      { name: "Amazon Prime Video", description: "Amazon's streaming service", website_url: "https://primevideo.com", country_code: "US" },
      { name: "Disney+", description: "Disney's streaming platform", website_url: "https://disneyplus.com", country_code: "US" },
      { name: "Hulu", description: "US streaming service", website_url: "https://hulu.com", country_code: "US" },
      { name: "BBC iPlayer", description: "BBC's streaming service", website_url: "https://bbc.co.uk/iplayer", country_code: "GB" },
      { name: "CBC Gem", description: "CBC's streaming platform", website_url: "https://gem.cbc.ca", country_code: "CA" }
    ]

    distributors_data.each do |dist_data|
      distributor = Distributor.find_or_create_by(name: dist_data[:name]) do |d|
        d.description = dist_data[:description]
        d.website_url = dist_data[:website_url]
        d.country_code = dist_data[:country_code]
        d.active = true
      end
      puts "  ✅ #{distributor.name}"
    end
    
    puts "✨ Distributors seeded!"
  end
end