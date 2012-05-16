class AddIndexes < ActiveRecord::Migration
  def up
    add_index :scenarios, :started
    add_index :scenarios, :completed
    add_index :scenarios, :failed
    add_index :scenarios, :succeeded
  end

  def down
  end
end
