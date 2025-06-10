class Distributor < ApplicationRecord
  # Validations
  validates :name, presence: true, uniqueness: true
  validates :country_code, presence: true, length: { is: 2 }

  # Associations
  has_many :tv_show_distributors, dependent: :destroy
  has_many :tv_shows, through: :tv_show_distributors
  has_many :release_dates, dependent: :destroy

  # Scopes - using 'active' column instead of 'is_active'
  scope :active, -> { where(active: true) }
  scope :by_country, ->(country) { where(country_code: country) }
end