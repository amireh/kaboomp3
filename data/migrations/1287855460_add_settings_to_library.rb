class AddSettingsToLibrary < ActiveRecord::Migration
  def self.up
    change_table :libraries do |t|
      t.string :path
      t.string :naming
      t.boolean :sort_by_genre
      t.boolean :sort_by_artist
      t.boolean :sort_by_album
      t.boolean :hard_copy
    end
  end

  def self.down
    remove_column :libraries, :path
    remove_column :libraries, :naming
    remove_column :libraries, :sort_by_genre
    remove_column :libraries, :sort_by_artist
    remove_column :libraries, :sort_by_album
    remove_column :libraries, :hard_copy
  end
end
