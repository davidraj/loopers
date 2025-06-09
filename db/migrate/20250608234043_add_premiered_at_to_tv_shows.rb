class AddPremieredAtToTvShows < ActiveRecord::Migration[8.0]
  def change
    add_column :tv_shows, :premiered_at, :date
  end
end
