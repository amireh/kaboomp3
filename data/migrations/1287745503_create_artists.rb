class CreateArtists < ActiveRecord::Migration
  def self.up
    create_table :artists do |t|
      t.string :name, :default => "Unknown Artist"
      
      t.timestamps
    end
  end

  def self.down
    drop_table :artists
  end
end