class AlasType < ApplicationRecord
  scope :ordered, -> { order(name: :asc) }
end
