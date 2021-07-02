class RemoveFileUploadToSubmissionFile < ActiveRecord::Migration[6.0]
  def change
    remove_column :submission_files, :file_upload_id
  end
end
