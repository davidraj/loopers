class TvShow < ApplicationRecord
  has_many :episodes, dependent: :destroy
  
  validates :tvmaze_id, presence: true, uniqueness: true
  validates :title, presence: true
end