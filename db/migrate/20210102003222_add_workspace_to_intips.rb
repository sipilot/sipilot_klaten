class AddWorkspaceToIntips < ActiveRecord::Migration[6.0]
  def change
    add_column :intips, :workspace_id, :integer
  end
end
