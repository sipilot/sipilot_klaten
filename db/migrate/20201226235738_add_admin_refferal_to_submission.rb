class AddAdminRefferalToSubmission < ActiveRecord::Migration[6.0]
  def change
    add_column :submissions, :admin_referral, :integer
  end
end
