class AddCompletedAtToRun < ActiveRecord::Migration
  def change
    add_column :runs, :completed_at, :timestamp
  end
end
