class AddColumnDistrictToArea < ActiveRecord::Migration[6.0]
  def change
    remove_column :working_areas, :district_id
    add_column :areas, :district_id, :integer
  end
end
