class Workspace < ApplicationRecord
  belongs_to :user
  belongs_to :village
  belongs_to :district
  belongs_to :sub_district
  has_many :gps_plottings
  has_many :intips

  def total_gps_plottings
    gps_plottings.where('sent_at IS NULL').count
  end

  def district_name
    district.name
  rescue StandardError
    ''
  end

  def sub_district_name
    sub_district.name
  rescue StandardError
    ''
  end

  def village_name
    village.name
  rescue StandardError
    ''
  end
end
