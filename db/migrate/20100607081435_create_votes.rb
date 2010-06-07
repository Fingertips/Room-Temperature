class CreateVotes < ActiveRecord::Migration
  def self.up
    create_table :votes do |t|
      t.string :client_token
      t.integer :stars
      t.timestamps
    end
  end

  def self.down
    drop_table :votes
  end
end
