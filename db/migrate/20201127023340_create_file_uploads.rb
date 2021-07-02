class CreateFileUploads < ActiveRecord::Migration[6.0]
  def change
    create_table :file_uploads do |t|
      t.text :data
      t.text :description

      t.timestamps
    end
  end
end
