class ReameColumnTypeToSubmissionTypeOnSubmissionFile < ActiveRecord::Migration[6.0]
  def change
    rename_column :submission_files, :type, :file_type
  end
end
