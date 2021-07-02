class CreateAreas < ActiveRecord::Migration[6.0]
  def change
    create_table :areas do |t|
      t.integer :area_id
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
