class AddStartedToRuns < ActiveRecord::Migration
  def change
    add_column :runs, :started, :boolean, :default=>false
  end
end
