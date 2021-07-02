class SubDistrict < ApplicationRecord
  has_many :villages, dependent: :destroy
  belongs_to :district

  scope :ordered, -> { order(name: :asc) }
end
