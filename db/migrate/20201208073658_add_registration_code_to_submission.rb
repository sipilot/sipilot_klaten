class AddRegistrationCodeToSubmission < ActiveRecord::Migration[6.0]
  def change
    add_column :submissions, :registration_code, :string
  end
end
