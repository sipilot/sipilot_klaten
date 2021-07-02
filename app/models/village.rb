class Village < ApplicationRecord
  belongs_to :sub_district

  scope :ordered, -> { order(name: :asc) }
end
