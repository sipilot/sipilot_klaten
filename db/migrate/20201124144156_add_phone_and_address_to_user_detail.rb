class AddPhoneAndAddressToUserDetail < ActiveRecord::Migration[6.0]
  def change
    add_column :user_details, :address, :text
    add_column :user_details, :phone_number, :text
  end
end
