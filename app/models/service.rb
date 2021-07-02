class Service < ApplicationRecord
  def self.validation_id
    where('name ILIKE ?', '%validasi%').first.id
  end

  def self.space_pattern_id
    where('name ILIKE ?', '%pola ruang%').first.id
  end
end
