class AddPingToNode < ActiveRecord::Migration
  def change
    add_column :nodes, :ping, :float
  end
end
