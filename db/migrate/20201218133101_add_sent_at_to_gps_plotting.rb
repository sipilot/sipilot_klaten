class AddSentAtToGpsPlotting < ActiveRecord::Migration[6.0]
  def change
    add_column :gps_plottings, :sent_at, :datetime
  end
end
