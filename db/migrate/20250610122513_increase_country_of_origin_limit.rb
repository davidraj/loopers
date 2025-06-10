class IncreaseCountryOfOriginLimit < ActiveRecord::Migration[8.0]
  def change
    change_column :tv_shows, :country_of_origin, :string, limit: 100
  end
end
