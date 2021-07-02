class AddColumnToNotification < ActiveRecord::Migration[6.0]
  def change
    add_column :notifications, :notif_type, :string
  end
end
