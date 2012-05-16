class AddErrorToNode < ActiveRecord::Migration
  def change
    add_column :nodes, :last_error, :string
  end
end
