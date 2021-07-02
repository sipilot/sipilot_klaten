class AddDistrictToSubDistrict < ActiveRecord::Migration[6.0]
  def change
    add_column :sub_districts, :district_id, :integer
  end
end
