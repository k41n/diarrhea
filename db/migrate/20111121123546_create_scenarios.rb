class CreateScenarios < ActiveRecord::Migration
  def change
    create_table :scenarios do |t|
      t.string :name
      t.text :stdout
      t.text :log
      t.references :feature_file
      t.references :node
      t.boolean :started, :default=>false
      t.timestamps
    end
  end
end
