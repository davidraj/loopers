class CreateTvShowDistributors < ActiveRecord::Migration[7.0]
  def change
    create_table :tv_show_distributors do |t|
      t.references :tv_show, null: false, foreign_key: true, index: false
      t.references :distributor, null: false, foreign_key: true, index: false
      t.string :distribution_type # e.g., 'streaming', 'broadcast', 'cable'
      t.string :region # e.g., 'US', 'UK', 'global'
      t.date :contract_start_date
      t.date :contract_end_date
      t.boolean :exclusive, default: false

      t.timestamps
    end

    # Index choices:
    # - Composite unique index prevents duplicate distributor-show combinations per region
    # - tv_show_id: Fast lookup of all distributors for a show
    # - distributor_id: Fast lookup of all shows for a distributor
    # - region: Geographic filtering of distribution deals
    # - contract_end_date: Finding expiring contracts
    add_index :tv_show_distributors, [:tv_show_id, :distributor_id, :region], 
              unique: true, name: 'index_tv_show_distributors_unique'
    add_index :tv_show_distributors, :tv_show_id
    add_index :tv_show_distributors, :distributor_id
    add_index :tv_show_distributors, :region
    add_index :tv_show_distributors, :contract_end_date
  end
end