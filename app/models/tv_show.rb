class TvShow < ApplicationRecord
  # Validations
  validates :title, presence: true
  validates :genre, presence: true
  validates :original_air_date, presence: true  # Changed from release_date to original_air_date

  # Associations
  has_many :episodes, dependent: :destroy
  has_many :user_tv_shows, dependent: :destroy
  has_many :users, through: :user_tv_shows
  has_many :tv_show_distributors, dependent: :destroy
  has_many :distributors, through: :tv_show_distributors
  has_many :release_dates, dependent: :destroy

  # Enums - String-based enum (since column is string)
  enum :status, { upcoming: "upcoming", running: "running", ended: "ended" }

  # Scopes
  scope :by_status, ->(status) { where(status: status) }
  scope :search, ->(query) { where("title ILIKE ?", "%#{query}%") }
  scope :by_genre, ->(genre) { where(genre: genre) }
  scope :released_after, ->(date) { where('original_air_date > ?', date) }  # Changed from release_date

  # Analytical Methods
  # Query 1: TV Shows with Episode Statistics using Window Functions
  def self.shows_with_episode_stats
    query = <<-SQL
      WITH episode_stats AS (
        SELECT 
          tv_shows.id,
          tv_shows.title,
          tv_shows.genre,
          tv_shows.original_air_date,  -- Changed from release_date
          COUNT(episodes.id) as total_episodes,
          AVG(episodes.duration) as avg_episode_duration,
          ROW_NUMBER() OVER (PARTITION BY tv_shows.genre ORDER BY COUNT(episodes.id) DESC) as genre_rank,
          RANK() OVER (ORDER BY COUNT(episodes.id) DESC) as overall_rank
        FROM tv_shows
        LEFT JOIN episodes ON tv_shows.id = episodes.tv_show_id
        GROUP BY tv_shows.id, tv_shows.title, tv_shows.genre, tv_shows.original_air_date
      )
      SELECT 
        id,
        title,
        genre,
        original_air_date,  -- Changed from release_date
        total_episodes,
        ROUND(avg_episode_duration, 2) as avg_episode_duration,
        genre_rank,
        overall_rank
      FROM episode_stats
      ORDER BY overall_rank, genre, title
    SQL

    find_by_sql(query)
  end

  # Query 2: Distribution Analysis with CTEs and Aggregates
  def self.distribution_analysis
    query = <<-SQL
      WITH distributor_stats AS (
        SELECT 
          d.id as distributor_id,
          d.name as distributor_name,
          d.country_code,
          COUNT(DISTINCT tsd.tv_show_id) as shows_distributed,
          COUNT(CASE WHEN tsd.exclusive = true THEN 1 END) as exclusive_deals,
          AVG(CASE WHEN tsd.contract_end_date IS NOT NULL AND tsd.contract_start_date IS NOT NULL 
              THEN tsd.contract_end_date - tsd.contract_start_date 
              ELSE NULL END) as avg_contract_duration
        FROM distributors d
        LEFT JOIN tv_show_distributors tsd ON d.id = tsd.distributor_id
        WHERE d.active = true
        GROUP BY d.id, d.name, d.country_code
      ),
      country_totals AS (
        SELECT 
          country_code,
          SUM(shows_distributed) as total_shows_in_country,
          COUNT(*) as distributors_count
        FROM distributor_stats
        GROUP BY country_code
      )
      SELECT 
        ds.distributor_id,
        ds.distributor_name,
        ds.country_code,
        ds.shows_distributed,
        ds.exclusive_deals,
        ROUND(ds.avg_contract_duration, 2) as avg_contract_duration_days,
        ct.total_shows_in_country,
        ct.distributors_count,
        ROUND((ds.shows_distributed::float / NULLIF(ct.total_shows_in_country, 0)) * 100, 2) as market_share_percentage
      FROM distributor_stats ds
      JOIN country_totals ct ON ds.country_code = ct.country_code
      ORDER BY ds.country_code, ds.shows_distributed DESC
    SQL

    find_by_sql(query)
  end

  # Query 3: Genre Performance Analysis with Window Functions
  def self.genre_performance_analysis
    query = <<-SQL
      WITH genre_metrics AS (
        SELECT 
          tv_shows.genre,
          COUNT(DISTINCT tv_shows.id) as total_shows,
          COUNT(DISTINCT episodes.id) as total_episodes,
          AVG(episodes.duration) as avg_episode_duration,
          COUNT(DISTINCT tv_show_distributors.distributor_id) as unique_distributors,
          COUNT(CASE WHEN tv_show_distributors.exclusive = true THEN 1 END) as exclusive_distributions,
          MIN(tv_shows.original_air_date) as earliest_show,  -- Changed from release_date
          MAX(tv_shows.original_air_date) as latest_show     -- Changed from release_date
        FROM tv_shows
        LEFT JOIN episodes ON tv_shows.id = episodes.tv_show_id
        LEFT JOIN tv_show_distributors ON tv_shows.id = tv_show_distributors.tv_show_id
        GROUP BY tv_shows.genre
      ),
      genre_rankings AS (
        SELECT 
          *,
          ROW_NUMBER() OVER (ORDER BY total_shows DESC) as shows_rank,
          ROW_NUMBER() OVER (ORDER BY total_episodes DESC) as episodes_rank,
          ROW_NUMBER() OVER (ORDER BY unique_distributors DESC) as distribution_rank,
          PERCENT_RANK() OVER (ORDER BY total_shows) as shows_percentile
        FROM genre_metrics
      )
      SELECT 
        genre,
        total_shows,
        total_episodes,
        ROUND(avg_episode_duration, 2) as avg_episode_duration,
        unique_distributors,
        exclusive_distributions,
        earliest_show,
        latest_show,
        shows_rank,
        episodes_rank,
        distribution_rank,
        ROUND(shows_percentile * 100, 2) as shows_percentile
      FROM genre_rankings
      ORDER BY shows_rank
    SQL

    find_by_sql(query)
  end

  # Helper method for getting top shows by episode count
  def self.top_shows_by_episodes(limit = 10)
    joins(:episodes)
      .select('tv_shows.*, COUNT(episodes.id) as episode_count')
      .group('tv_shows.id')
      .order('episode_count DESC')
      .limit(limit)
  end
end
