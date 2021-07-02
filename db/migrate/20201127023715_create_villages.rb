class CreateVillages < ActiveRecord::Migration[6.0]
  def change
    create_table :villages do |t|
      t.string :name
      t.text :description
      t.references :sub_district, null: false, foreign_key: true

      t.timestamps
    end
  end
end
