namespace :ingestion do
  desc "Daily ingestion of upcoming releases for next 90 days"
  task daily_upcoming: :environment do
    TvMazeUpcomingService.new.fetch_upcoming_releases(90)
  end
end