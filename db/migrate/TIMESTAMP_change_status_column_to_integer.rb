class ChangeStatusColumnToInteger < ActiveRecord::Migration[8.0]
  def up
    # First update any NULL values
    execute "UPDATE tv_shows SET status = 'upcoming' WHERE status IS NULL"
    
    # Change the column type using PostgreSQL syntax
    execute <<-SQL
      ALTER TABLE tv_shows 
      ALTER COLUMN status TYPE integer 
      USING CASE 
        WHEN status = 'upcoming' THEN 0
        WHEN status = 'running' THEN 1
        WHEN status = 'ended' THEN 2
        ELSE 0
      END
    SQL
    
    # Set the default value
    change_column_default :tv_shows, :status, 0
  end

  def down
    execute <<-SQL
      ALTER TABLE tv_shows 
      ALTER COLUMN status TYPE varchar 
      USING CASE 
        WHEN status = 0 THEN 'upcoming'
        WHEN status = 1 THEN 'running'
        WHEN status = 2 THEN 'ended'
        ELSE 'upcoming'
      END
    SQL
    
    change_column_default :tv_shows, :status, 'upcoming'
  end
end