class CreateFeatureFiles < ActiveRecord::Migration
  def change
    create_table :feature_files do |t|
      t.string :name
      t.references :run
      t.timestamps
    end
  end
end
