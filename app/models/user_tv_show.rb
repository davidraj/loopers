class UserTvShow < ApplicationRecord
  belongs_to :user
  belongs_to :tv_show

  validates :user_id, uniqueness: { scope: :tv_show_id }
end
