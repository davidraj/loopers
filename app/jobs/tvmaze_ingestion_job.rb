require "net/http"
require "json"

class TvmazeIngestionJob < ApplicationJob
  queue_as :default

  def perform
    puts "Starting daily 90-day TV Maze ingestion..."
    result = TvMazeUpcomingService.new.fetch_upcoming_releases(90)
    puts "Completed: #{result[:message]}"
    result
  end
end
