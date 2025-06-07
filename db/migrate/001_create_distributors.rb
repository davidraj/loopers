class CreateDistributors < ActiveRecord::Migration[7.0]
  def change
    create_table :distributors do |t|
      t.string :name, null: false
      t.text :description
      t.string :website_url
      t.string :country_code, limit: 2
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    # Index choices:
    # - name: Frequently searched/filtered by distributor name
    # - active: Common filter to show only active distributors
    # - country_code: Geographic filtering and grouping
    add_index :distributors, :name, unique: true
    add_index :distributors, :active
    add_index :distributors, :country_code
  end
end