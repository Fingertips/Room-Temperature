class AddIndexToClientToken < ActiveRecord::Migration
  def self.up
    add_index :votes, :client_token
  end

  def self.down
    remove_index :votes, :client_token
  end
end
