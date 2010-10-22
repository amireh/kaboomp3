class CreateTracks < ActiveRecord::Migration
  def self.up
    create_table :tracks do |t|
      t.string :title, :default => "Untitled Track"
      t.string :codec, :default => "mp3"
      t.string :signature
      
      t.references :album
      t.references :library
      
      t.timestamps
    end
  end

  def self.down
    drop_table :tracks
  end
end
