class AddAlasHakNumberToGpsPlotting < ActiveRecord::Migration[6.0]
  def change
    add_column :gps_plottings, :alas_hak_number, :string
  end
end
