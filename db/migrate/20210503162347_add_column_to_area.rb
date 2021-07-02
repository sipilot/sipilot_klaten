class AddColumnToArea < ActiveRecord::Migration[6.0]
  def change
    add_column :areas, :base_url, :string
  end
end
