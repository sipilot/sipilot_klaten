class CreateGpsPlottings < ActiveRecord::Migration[6.0]
  def change
    create_table :gps_plottings do |t|
      t.string :fullname
      t.string :on_behalf
      t.integer :act_for
      t.string :hak_number

      t.string :lattitude
      t.string :longitude
      t.text :land_address

      t.datetime :deleted_at
      t.references :user, null: false, foreign_key: true
      t.references :sub_district, null: false, foreign_key: true
      t.references :village, null: false, foreign_key: true
      t.references :hak_type, null: false, foreign_key: true

      t.timestamps
    end
  end
end
