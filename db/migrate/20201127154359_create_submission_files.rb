class CreateSubmissionFiles < ActiveRecord::Migration[6.0]
  def change
    create_table :submission_files do |t|
      t.text :description
      t.integer :type
      t.references :submission, null: false, foreign_key: true
      t.references :file_upload, null: false, foreign_key: true

      t.timestamps
    end
  end
end
