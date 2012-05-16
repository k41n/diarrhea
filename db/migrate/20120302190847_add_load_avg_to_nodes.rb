class AddLoadAvgToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :load15, :float
    add_column :nodes, :load10, :float
    add_column :nodes, :load5, :float
  end
end
