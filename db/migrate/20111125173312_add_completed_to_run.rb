class AddCompletedToRun < ActiveRecord::Migration
  def change
    add_column :runs, :completed, :boolean, :default => false
  end
end
