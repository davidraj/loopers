class Api::V1::AnalyticsController < ApplicationController
  def episode_stats
    stats = TvShow.shows_with_episode_stats
    
    render json: {
      data: stats.map do |stat|
        {
          id: stat.id,
          title: stat.title,
          genre: stat.genre,
          total_episodes: stat.total_episodes.to_i,
          avg_episode_duration: stat.avg_episode_duration.to_f.round(2),
          genre_rank: stat.genre_rank.to_i,
          overall_rank: stat.overall_rank.to_i
        }
      end,
      meta: {
        generated_at: Time.current.iso8601,
        total_shows: stats.length
      }
    }
  end

  def distribution_analysis
    analysis = TvShow.distribution_analysis
    
    render json: {
      data: analysis.map do |dist|
        {
          distributor_id: dist.distributor_id.to_i,
          distributor_name: dist.distributor_name,
          country_code: dist.country_code,
          shows_distributed: dist.shows_distributed.to_i,
          exclusive_deals: dist.exclusive_deals.to_i,
          avg_contract_duration_days: dist.avg_contract_duration_days.to_f.round(2),
          market_share_percentage: dist.market_share_percentage.to_f.round(2)
        }
      end,
      meta: {
        generated_at: Time.current.iso8601,
        total_distributors: analysis.length
      }
    }
  end

  def genre_performance
    performance = TvShow.genre_performance_analysis
    
    render json: {
      data: performance.map do |genre|
        {
          genre: genre.genre,
          total_shows: genre.total_shows.to_i,
          total_episodes: genre.total_episodes.to_i,
          avg_episode_duration: genre.avg_episode_duration.to_f.round(2),
          unique_distributors: genre.unique_distributors.to_i,
          shows_rank: genre.shows_rank.to_i,
          shows_percentile: genre.shows_percentile.to_f.round(2)
        }
      end,
      meta: {
        generated_at: Time.current.iso8601,
        total_genres: performance.length
      }
    }
  end
end