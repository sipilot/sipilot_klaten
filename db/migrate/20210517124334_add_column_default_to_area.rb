class AddColumnDefaultToArea < ActiveRecord::Migration[6.0]
  def change
    add_column :areas, :is_default, :boolean, default: false
  end
end
