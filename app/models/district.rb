class District < ApplicationRecord
  has_many :sub_districts, dependent: :destroy

  scope :ordered, -> { order(name: :asc) }
end
