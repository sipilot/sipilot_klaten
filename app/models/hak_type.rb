class HakType < ApplicationRecord
  scope :ordered, -> { order(name: :asc) }
  scope :without_certificate_status, -> { where('name != ?', 'Belum Sertifikat') }
end
