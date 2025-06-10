require "net/http"
require "json"

class TvmazeIngestionJob < ApplicationJob
  queue_as :default

  def perform(pages: 10, import_episodes: true)
    puts "Starting TVMaze ingestion for #{pages} pages (episodes: #{import_episodes})"
    
    total_shows = 0
    total_episodes = 0
    
    (1..pages).each do |page|
      puts "Processing page #{page}"
      
      begin
        # Fetch shows from TVMaze API
        uri = URI("https://api.tvmaze.com/shows?page=#{page - 1}")
        response = Net::HTTP.get_response(uri)
        
        if response.code == "200"
          shows_data = JSON.parse(response.body)
          puts "Found #{shows_data.length} shows on page #{page}"
          
          shows_data.each do |show_data|
            show_name = show_data["name"]
            show_id = show_data["id"]
            
            # Create or update TV show
            tv_show = TvShow.find_or_create_by(tvmaze_id: show_id) do |show|
              puts "Creating new show: #{show_name}"
              show.title = show_name&.truncate(255)
              show.summary = show_data["summary"]
              show.premiered_at = show_data["premiered"]
              show.status = show_data["status"]&.truncate(50)
              show.rating = show_data.dig("rating", "average")
              show.genre = show_data["genres"]&.join(", ")&.truncate(100)
              show.language = show_data["language"]&.truncate(50)
              show.network_name = show_data.dig("network", "name")&.truncate(100)
              show.image_url = show_data.dig("image", "medium")&.truncate(500)
              show.country_of_origin = show_data.dig("network", "country", "name")&.truncate(100)
              show.runtime_minutes = show_data["runtime"]
              show.original_air_date = show_data["premiered"]
            end
            
            if tv_show.persisted?
              total_shows += 1 if tv_show.created_at == tv_show.updated_at
              
              # Import episodes if requested
              if import_episodes
                episode_count = import_episodes_for_show(tv_show, show_id)
                total_episodes += episode_count
              end
            end
            
            # Small delay to be respectful to the API
            sleep(0.1)
          end
        else
          puts "Failed to fetch page #{page}: #{response.code}"
          break if response.code == "404"
        end
        
      rescue => e
        puts "Error processing page #{page}: #{e.message}"
        next
      end
    end
    
    puts "TVMaze ingestion completed. Shows: #{total_shows}, Episodes: #{total_episodes}"
    
    {
      shows_imported: total_shows,
      episodes_imported: total_episodes,
      pages_processed: pages
    }
  end
  
  private
  
  def import_episodes_for_show(tv_show, show_id)
    return 0 if tv_show.episodes.any? # Skip if episodes already imported
    
    episode_count = 0
    
    begin
      episodes_uri = URI("https://api.tvmaze.com/shows/#{show_id}/episodes")
      episodes_response = Net::HTTP.get_response(episodes_uri)
      
      if episodes_response.code == "200"
        episodes_data = JSON.parse(episodes_response.body)
        puts "  Importing #{episodes_data.length} episodes for #{tv_show.title}"
        
        episodes_data.each do |episode_data|
          episode = Episode.find_or_create_by(
            tv_show: tv_show,
            tvmaze_id: episode_data["id"]
          ) do |ep|
            ep.title = episode_data["name"]&.truncate(255)
            ep.season_number = episode_data["season"]
            ep.episode_number = episode_data["number"]
            ep.air_date = episode_data["airdate"]
            ep.runtime = episode_data["runtime"]
            ep.summary = episode_data["summary"]
          end
          
          episode_count += 1 if episode.persisted?
        end
      end
      
      # Update show episode count
      tv_show.update(total_episodes: episode_count) if episode_count > 0
      
    rescue => e
      puts "  Error importing episodes for #{tv_show.title}: #{e.message}"
    end
    
    episode_count
  end
end
