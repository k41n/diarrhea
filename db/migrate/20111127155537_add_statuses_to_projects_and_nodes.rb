class AddStatusesToProjectsAndNodes < ActiveRecord::Migration
  def change
    add_column :projects, :status, :string
    add_column :projects, :locked, :boolean, :default => false
    add_column :nodes, :status, :string
    add_column :nodes, :locked, :boolean, :default => false
  end
end
