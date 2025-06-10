class TvShow < ApplicationRecord
  # Validations
  validates :title, presence: true
  validates :tvmaze_id, uniqueness: true, allow_nil: true

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
end
