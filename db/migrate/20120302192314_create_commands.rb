class CreateCommands < ActiveRecord::Migration
  def change
    create_table :commands do |t|
      t.string :cmdline
      t.string :result
      t.references :node
      t.timestamps
    end
  end
end
