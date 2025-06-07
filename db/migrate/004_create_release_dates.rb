class CreateReleaseDates < ActiveRecord::Migration[7.0]
  def change
    create_table :release_dates do |t|
      t.references :tv_show, null: false, foreign_key: true
      t.references :distributor, null: false, foreign_key: true
      t.date :release_date, null: false
      t.string :region, null: false
      t.string :release_type # e.g., 'premiere', 'season_premiere', 'finale'
      t.integer :season_number
      t.integer :episode_number
      t.text :notes

      t.timestamps
    end

    # Index choices:
    # - tv_show_id + release_date: Chronological listing of show releases
    # - distributor_id + release_date: Distributor's release schedule
    # - region + release_date: Regional release calendars
    # - release_date: Global release calendar and date range queries
    # - season/episode composite: Quick lookup for specific episodes
    add_index :release_dates, [:tv_show_id, :release_date]
    add_index :release_dates, [:distributor_id, :release_date]
    add_index :release_dates, [:region, :release_date]
    add_index :release_dates, :release_date
    add_index :release_dates, [:tv_show_id, :season_number, :episode_number], 
              name: 'index_release_dates_on_show_season_episode'
  end
end