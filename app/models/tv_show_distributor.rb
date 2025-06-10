class TvShowDistributor < ApplicationRecord
  # Associations
  belongs_to :tv_show
  belongs_to :distributor

  # Validations
  validates :tv_show, presence: true
  validates :distributor, presence: true
  validates :tv_show_id, uniqueness: { scope: :distributor_id }
end