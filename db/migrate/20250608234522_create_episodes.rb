class CreateEpisodes < ActiveRecord::Migration[8.0]
  def change
    create_table :episodes do |t|
      t.references :tv_show, null: false, foreign_key: true
      t.string :title
      t.text :summary
      t.date :air_date
      t.integer :season_number
      t.integer :episode_number
      t.integer :tvmaze_id
      t.integer :runtime

      t.timestamps
    end
  end
end
