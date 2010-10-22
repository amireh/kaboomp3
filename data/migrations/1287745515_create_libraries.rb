class CreateLibraries < ActiveRecord::Migration
  def self.up
    create_table :libraries do |t|
      t.string :title, :default => "Untitled Library"
      t.string :emblem
      
      t.references :library
    end
  end

  def self.down
    drop_table :libraries
  end
end
