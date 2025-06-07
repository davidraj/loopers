class CreateTvShows < ActiveRecord::Migration[7.0]
  def change
    create_table :tv_shows do |t|
      t.string :title, null: false
      t.text :description
      t.string :genre
      t.integer :total_seasons
      t.integer :total_episodes
      t.string :status, default: 'upcoming'
      t.decimal :imdb_rating, precision: 3, scale: 1
      t.string :language, default: 'en'
      t.integer :runtime_minutes
      t.date :original_air_date
      t.string :country_of_origin, limit: 2

      t.timestamps
    end

    # Index choices:
    # - title: Primary search field for TV shows
    # - genre: Common filtering criteria
    # - status: Filter by show status (airing, ended, upcoming, etc.)
    # - original_air_date: Chronological sorting and date range queries
    # - imdb_rating: Sorting by rating, finding top-rated shows
    # - language: Filtering by language preference
    add_index :tv_shows, :title
    add_index :tv_shows, :genre
    add_index :tv_shows, :status
    add_index :tv_shows, :original_air_date
    add_index :tv_shows, :imdb_rating
    add_index :tv_shows, :language
  end
end