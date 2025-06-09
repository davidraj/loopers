class AddMissingColumnsToTvShows < ActiveRecord::Migration[8.0]
  def change
    add_column :tv_shows, :summary, :text
    add_column :tv_shows, :network_name, :string
    add_column :tv_shows, :rating, :decimal
  end
end
