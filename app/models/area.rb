class Area < ApplicationRecord
  belongs_to :district, optional: true
  has_many :working_areas, dependent: :destroy

  scope :ordered, -> { order(name: :asc) }
end
