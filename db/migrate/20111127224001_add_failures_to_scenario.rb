class AddFailuresToScenario < ActiveRecord::Migration
  def change
    add_column :scenarios, :failures, :integer, :default => 0
  end
end
