namespace :tv_shows do
  desc "Fetch upcoming TV show releases from TVMaze"
  task fetch_upcoming: :environment do
    puts "Starting TVMaze upcoming releases fetch..."
    
    service = TvMazeUpcomingService.new
    result = service.fetch_upcoming_releases(7) # Fetch 7 days ahead
    
    if result[:success]
      puts "✅ Success: #{result[:message]}"
    else
      puts "❌ Error: #{result[:message]}"
    end
  end
  
  desc "Fetch popular TV shows from TVMaze"
  task fetch_popular: :environment do
    puts "Fetching popular shows..."
    # We can add this later
  end
end