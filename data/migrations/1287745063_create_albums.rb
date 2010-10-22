class CreateAlbums < ActiveRecord::Migration
  def self.up
    create_table :albums do |t|
      t.string :title, :default => "Untitled Album"
      t.string :publisher
      t.integer :publish_year
      
      t.references :genre
      t.references :artist
      
      t.timestamps
    end
  end

  def self.down
    drop_table :albums
  end
end
