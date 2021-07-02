class AddStatusToGpsPlotting < ActiveRecord::Migration[6.0]
  def change
    add_column :gps_plottings, :status, :integer
  end
end
