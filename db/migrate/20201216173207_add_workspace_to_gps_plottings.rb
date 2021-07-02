class AddWorkspaceToGpsPlottings < ActiveRecord::Migration[6.0]
  def change
    add_column :gps_plottings, :workspace_id, :integer
  end
end
