class ConvertTvShowStatusToInteger < ActiveRecord::Migration[8.0]
  def up
    # First, update existing string values to match our enum
    execute "UPDATE tv_shows SET status = 'upcoming' WHERE status IS NULL OR status = ''"
    
    # Add a temporary column
    add_column :tv_shows, :status_temp, :integer, default: 0
    
    # Convert existing data
    execute <<-SQL
      UPDATE tv_shows SET status_temp = CASE 
        WHEN status = 'upcoming' THEN 0
        WHEN status = 'running' THEN 1  
        WHEN status = 'ended' THEN 2
        ELSE 0
      END
    SQL
    
    # Remove old column and rename new one
    remove_column :tv_shows, :status
    rename_column :tv_shows, :status_temp, :status
  end

  def down
    # Add temporary string column
    add_column :tv_shows, :status_temp, :string
    
    # Convert back to strings
    execute <<-SQL
      UPDATE tv_shows SET status_temp = CASE 
        WHEN status = 0 THEN 'upcoming'
        WHEN status = 1 THEN 'running'
        WHEN status = 2 THEN 'ended'
        ELSE 'upcoming'
      END
    SQL
    
    # Remove integer column and rename string one
    remove_column :tv_shows, :status
    rename_column :tv_shows, :status_temp, :status
  end
end