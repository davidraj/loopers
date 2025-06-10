class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true

  has_many :user_tv_shows, dependent: :destroy
  has_many :tv_shows, through: :user_tv_shows
end
