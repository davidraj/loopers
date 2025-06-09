class AddTvmazeIdToTvShows < ActiveRecord::Migration[8.0]
  def change
    add_column :tv_shows, :tvmaze_id, :integer
  end
end
