class CreateUserDetails < ActiveRecord::Migration[6.0]
  def change
    create_table :user_details do |t|
      t.string :username
      t.string :fullname
      t.string :id_number
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
