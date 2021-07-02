class AddColumnIsDeletedToSubmission < ActiveRecord::Migration[6.0]
  def change
    add_column :submissions, :is_deleted, :boolean, default: false
    add_column :submissions, :deleted_at, :date
  end
end
