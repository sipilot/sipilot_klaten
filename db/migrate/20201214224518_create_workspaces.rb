class CreateWorkspaces < ActiveRecord::Migration[6.0]
  def change
    create_table :workspaces do |t|
      t.references :village, null: false, foreign_key: true
      t.references :sub_district, null: false, foreign_key: true
      t.references :district, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :rt
      t.string :rw
      t.datetime :date_from
      t.datetime :date_to

      t.timestamps
    end
  end
end
