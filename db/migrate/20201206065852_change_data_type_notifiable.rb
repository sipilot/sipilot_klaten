class ChangeDataTypeNotifiable < ActiveRecord::Migration[6.0]
  def change
    change_column :notifications, :notifiable_type, :string
  end
end
