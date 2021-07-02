class CreateWorkingAreas < ActiveRecord::Migration[6.0]
  def change
    create_table :working_areas do |t|
      t.references :area, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :district, null: false, foreign_key: true

      t.timestamps
    end
  end
end
