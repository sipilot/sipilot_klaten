class AddSentAtToIntips < ActiveRecord::Migration[6.0]
  def change
    add_column :intips, :sent_at, :datetime
  end
end
