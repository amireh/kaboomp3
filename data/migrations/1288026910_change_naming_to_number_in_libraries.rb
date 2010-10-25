class ChangeNamingToNumberInLibraries < ActiveRecord::Migration
  def self.up
    remove_column :libraries, :naming
    add_column :libraries, :naming, :integer
  end

  def self.down
    remove_column :libraries, :naming
    add_column :libraries, :naming, :string
  end
end
