class AddNibToSubmission < ActiveRecord::Migration[6.0]
  def change
    add_column :submissions, :nib, :string
  end
end
