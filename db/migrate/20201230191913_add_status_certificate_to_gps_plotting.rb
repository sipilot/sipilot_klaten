class AddStatusCertificateToGpsPlotting < ActiveRecord::Migration[6.0]
  def change
    add_column :gps_plottings, :certificate_status, :integer
  end
end
