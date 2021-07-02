class CreateIntips < ActiveRecord::Migration[6.0]
  def change
    create_table :intips do |t|
      t.references :sub_district, null: false, foreign_key: true
      t.references :village, null: false, foreign_key: true

      t.string :nui
      t.string :nib
      t.string :name
      t.datetime :date
      t.string :time_range

      t.string :land_control
      t.string :land_allocation
      t.string :land_use
      t.string :land_utilization

      t.string :land_size
      t.string :land_address
      t.string :description
      t.string :lattitude
      t.string :longitude
      t.string :number_letter_c
      t.string :hak_type
      t.string :hak_number
      t.integer :status
      t.integer :user_id

      t.timestamps
    end
  end
end
