class AddTimestampsToLibrary < ActiveRecord::Migration
  def self.up
    change_table :libraries do |t|
      t.timestamps
    end
  end

  def self.down
    remove_column :libraries, :created_at
    remove_column :libraries, :updated_at
  end
end
