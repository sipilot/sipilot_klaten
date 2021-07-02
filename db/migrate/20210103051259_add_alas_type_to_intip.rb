class AddAlasTypeToIntip < ActiveRecord::Migration[6.0]
  def change
    add_column :intips, :alas_type_id, :integer
  end
end
