class CreateRooms < ActiveRecord::Migration
  def self.up
    create_table :rooms do |t|
      t.string :title
      t.string :slug
      t.timestamps
    end
    add_column :votes, :room_id, :integer
    add_index :votes, :room_id
    
    Vote.connection.execute("UPDATE votes SET room_id = 1 WHERE room_id IS NULL")
  end
  
  def self.down
    remove_index :votes, :room_id
    remove_column :votes, :room_id
    drop_table :rooms
  end
end
