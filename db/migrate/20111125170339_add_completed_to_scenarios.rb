class AddCompletedToScenarios < ActiveRecord::Migration
  def change
    add_column :scenarios, :completed, :boolean, :default=>false
  end
end
