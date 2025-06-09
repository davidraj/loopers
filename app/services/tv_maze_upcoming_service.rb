class TvMazeUpcomingService
  include HTTParty
  base_uri 'https://api.tvmaze.com'

  def fetch_upcoming_releases(days = 7)
    total_episodes = 0
    processed_shows = 0
    episodes_created = 0

    (0...days).each do |day_offset|
      date = (Date.current + day_offset).strftime('%Y-%m-%d')
      
      begin
        response = self.class.get("/schedule?country=US&date=#{date}")
        
        if response.success?
          episodes = response.parsed_response
          total_episodes += episodes.count
          
          episodes.each do |episode_data|
            begin
              puts "\n--- Processing Episode ---"
              puts "Episode: #{episode_data['name']}"
              puts "Show: #{episode_data.dig('show', 'name')}"
              
              process_episode(episode_data)
              episodes_created += 1
              puts "✅ Episode created successfully"
            rescue => e
              show_name = episode_data.dig('show', 'name') || 'Unknown'
              episode_name = episode_data['name'] || 'Unknown'
              puts "❌ Error processing episode '#{episode_name}' for show '#{show_name}': #{e.message}"
              puts "Full error: #{e.class}: #{e.message}"
              puts "Backtrace: #{e.backtrace.first(3).join("\n")}"
            end
          end
          
          processed_shows += episodes.count
        else
          puts "Failed to fetch data for #{date}: #{response.code}"
        end
      rescue => e
        puts "Error fetching data for #{date}: #{e.message}"
      end
    end

    {
      success: true,
      total_episodes: total_episodes,
      processed_shows: processed_shows,
      episodes_created: episodes_created,
      message: "Successfully processed #{processed_shows} shows and created #{episodes_created} episodes from #{total_episodes} total episodes"
    }
  end

  private

  def process_episode(episode_data)
    show_data = episode_data['show']
    return unless show_data

    puts "  Finding or creating TV show..."
    tv_show = find_or_create_tv_show(show_data)
    return unless tv_show
    puts "  TV show ready: #{tv_show.title}"

    puts "  Creating episode..."
    create_episode_for_show(episode_data, tv_show)
    puts "  Episode created!"
  end

  def find_or_create_tv_show(show_data)
    tvmaze_id = show_data['id']
    return nil unless tvmaze_id

    tv_show = TvShow.find_by(tvmaze_id: tvmaze_id)
    if tv_show
      puts "    Found existing TV show: #{tv_show.title}"
      return tv_show
    end

    puts "    Creating new TV show: #{show_data['name']}"
    
    # Debug the attributes being created
    attrs = {
      title: show_data['name'],
      description: extract_text_from_html(show_data['summary']),
      genre: extract_genres(show_data['genres']),
      status: show_data['status'],
      imdb_rating: show_data.dig('rating', 'average'),
      language: show_data['language'],
      runtime_minutes: show_data['runtime'],
      original_air_date: show_data['premiered'],
      country_of_origin: show_data.dig('network', 'country', 'name') || show_data.dig('webChannel', 'country', 'name'),
      tvmaze_id: tvmaze_id,
      premiered_at: show_data['premiered'],
      image_url: show_data.dig('image', 'medium'),
      summary: extract_text_from_html(show_data['summary']),
      network_name: show_data.dig('network', 'name') || show_data.dig('webChannel', 'name'),
      rating: show_data.dig('rating', 'average')
    }

    # Check for potentially problematic values
    attrs.each do |key, value|
      if value.is_a?(String) && value.length > 100
        puts "    Long #{key}: #{value.length} chars"
      end
    end

    TvShow.create!(attrs)
  rescue ActiveRecord::RecordInvalid => e
    puts "❌ Failed to create TV show: #{e.message}"
    puts "Show data: #{show_data.inspect}"
    nil
  end

  def create_episode_for_show(episode_data, tv_show)
    # Check if episode already exists
    existing_episode = Episode.find_by(
      tv_show: tv_show,
      tvmaze_id: episode_data['id']
    )
    if existing_episode
      puts "    Found existing episode: #{existing_episode.title}"
      return existing_episode
    end

    episode_attrs = {
      title: episode_data['name'],
      season_number: episode_data['season'],
      episode_number: episode_data['number'],
      air_date: episode_data['airdate'],
      runtime: episode_data['runtime'],
      summary: extract_text_from_html(episode_data['summary']),
      tvmaze_id: episode_data['id'],
      tv_show: tv_show
    }

    puts "    Episode attributes:"
    episode_attrs.each do |key, value|
      puts "      #{key}: #{value.inspect}"
    end

    Episode.create!(episode_attrs)
  rescue => e
    puts "❌ Episode creation failed: #{e.message}"
    puts "Episode data: #{episode_data.inspect}"
    raise e
  end

  def extract_text_from_html(html_string)
    return nil if html_string.blank?
    
    # Remove HTML tags and decode HTML entities
    ActionView::Base.full_sanitizer.sanitize(html_string)
  end

  def extract_genres(genres_array)
    return '' if genres_array.blank?
    
    genres_array.join(', ')
  end
end