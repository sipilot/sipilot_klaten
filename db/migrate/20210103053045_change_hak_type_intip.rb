class ChangeHakTypeIntip < ActiveRecord::Migration[6.0]
  def change
    remove_column :intips, :hak_type
    add_column :intips, :hak_type_id, :integer
  end
end
