class TvShow < ApplicationRecord
  has_many :tv_show_distributors, dependent: :destroy
  has_many :distributors, through: :tv_show_distributors
  has_many :release_dates, dependent: :destroy

  validates :title, presence: true, length: { maximum: 255 }
  validates :status, inclusion: { in: %w[upcoming airing ended cancelled] }
  validates :imdb_rating, numericality: { 
    greater_than_or_equal_to: 0.0, 
    less_than_or_equal_to: 10.0,
    allow_nil: true 
  }
  validates :total_seasons, :total_episodes, :runtime_minutes, 
            numericality: { greater_than: 0, allow_nil: true }
  validates :language, :country_of_origin, format: { with: /\A[a-z]{2}\z/, allow_blank: true }

  scope :by_genre, ->(genre) { where(genre: genre) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_language, ->(language) { where(language: language) }
  scope :top_rated, -> { where.not(imdb_rating: nil).order(imdb_rating: :desc) }
  scope :recent, -> { order(original_air_date: :desc) }
end