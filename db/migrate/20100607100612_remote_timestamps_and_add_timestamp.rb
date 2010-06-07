class RemoteTimestampsAndAddTimestamp < ActiveRecord::Migration
  def self.up
    remove_column :votes, :created_at
    remove_column :votes, :updated_at
    add_column :votes, :timestamp, :integer
    add_index :votes, :timestamp
  end

  def self.down
    add_column :votes, :created_at, :datetime
    add_column :votes, :updated_at, :datetime
    remove_index :votes, :timestamp
    remove_column :votes, :timestamp
  end
end
