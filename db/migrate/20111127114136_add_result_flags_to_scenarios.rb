class AddResultFlagsToScenarios < ActiveRecord::Migration
  def change
    add_column :scenarios, :succeeded, :boolean
    add_column :scenarios, :failed, :boolean
  end
end
