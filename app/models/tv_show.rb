class TvShow < ApplicationRecord
  # Associations
  has_many :episodes, dependent: :destroy
  has_many :tv_show_distributors, dependent: :destroy
  has_many :distributors, through: :tv_show_distributors
  has_many :release_dates, dependent: :destroy

  # Scopes for filtering
  scope :by_date_range, ->(date_from, date_to) {
    where(original_air_date: date_from..date_to) if date_from.present? && date_to.present?
  }
  
  scope :by_rating, ->(min_rating) {
    where('imdb_rating >= ?', min_rating) if min_rating.present?
  }
  
  scope :by_country, ->(country) {
    where('country_of_origin ILIKE ?', "%#{country}%") if country.present?
  }
  
  scope :by_genre, ->(genre) {
    where('genre ILIKE ?', "%#{genre}%") if genre.present?
  }
  
  # Validations
  validates :title, presence: true
  validates :tvmaze_id, uniqueness: true, allow_nil: true
  
  # Default scope for ordering
  scope :ordered, -> { order(:title) }
end
