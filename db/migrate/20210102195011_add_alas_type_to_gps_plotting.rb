class AddAlasTypeToGpsPlotting < ActiveRecord::Migration[6.0]
  def change
    add_column :gps_plottings, :alas_type_id, :integer
  end
end
