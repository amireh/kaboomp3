class CreateGenres < ActiveRecord::Migration
  def self.up
    create_table :genres do |t|
      t.string :title, :null => false
    end
  end

  def self.down
    drop_table :genres
  end
end