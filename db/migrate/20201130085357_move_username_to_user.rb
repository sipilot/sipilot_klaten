class MoveUsernameToUser < ActiveRecord::Migration[6.0]
  def change
    remove_column :user_details, :username
  end
end
