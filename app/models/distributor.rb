class Distributor < ApplicationRecord
  has_many :tv_show_distributors, dependent: :destroy
  has_many :tv_shows, through: :tv_show_distributors

  validates :name, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :website_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }
  validates :country_code, format: { with: /\A[A-Z]{2}\z/, allow_blank: true }

  scope :active, -> { where(active: true) }
  scope :by_country, ->(country) { where(country_code: country) }
end