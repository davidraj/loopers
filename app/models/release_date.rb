class ReleaseDate < ApplicationRecord
  belongs_to :tv_show
  belongs_to :distributor

  validates :release_date, presence: true
  validates :region, presence: true, format: { with: /\A[A-Z]{2}|global\z/ }
  validates :release_type, inclusion: { 
    in: %w[premiere season_premiere season_finale series_finale episode],
    allow_blank: true 
  }
  validates :season_number, :episode_number, 
            numericality: { greater_than: 0, allow_nil: true }

  scope :upcoming, -> { where('release_date > ?', Date.current) }
  scope :past, -> { where('release_date <= ?', Date.current) }
  scope :by_region, ->(region) { where(region: region) }
  scope :by_release_type, ->(type) { where(release_type: type) }
  scope :chronological, -> { order(:release_date) }
  scope :for_season, ->(season) { where(season_number: season) }
end