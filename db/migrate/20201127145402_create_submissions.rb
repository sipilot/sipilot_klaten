class CreateSubmissions < ActiveRecord::Migration[6.0]
  def change
    create_table :submissions do |t|
      t.string :fullname
      t.string :on_behalf
      t.integer :act_for
      t.date :submission_date
      t.string :submission_code

      t.string :lattitude
      t.string :longitude
      t.text :land_address

      t.string :hak_number
      t.date :pick_up_date
      t.date :date_of_completion
      t.text :notes

      t.string :submission_status
      t.string :land_book_status
      t.text :land_book_description
      t.string :kasubsi_status
      t.string :kasubsi_registration_status
      t.string :kasubsi_tematik_status
      t.string :kasubsi_space_pattern_status
      t.string :space_pattern_status

      t.references :user, null: false, foreign_key: true
      t.references :hak_type, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true
      t.references :sub_district, null: false, foreign_key: true
      t.references :village, null: false, foreign_key: true

      t.timestamps
    end
  end
end
