class AddColumnToSubmissionFile < ActiveRecord::Migration[6.0]
  def change
    add_column :submission_files, :submissionable_id, :integer
    add_column :submission_files, :submissionable_type, :string
    remove_column :submission_files, :submission_id
  end
end
