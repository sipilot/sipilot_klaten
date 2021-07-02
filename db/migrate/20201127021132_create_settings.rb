class CreateSettings < ActiveRecord::Migration[6.0]
  def change
    create_table :settings do |t|
      t.string :name
      t.string :value
      t.text :description

      t.timestamps
    end
  end
end
