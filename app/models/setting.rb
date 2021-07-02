class Setting < ApplicationRecord
  def self.close_hour
    find_by(name: 'Jam Tutup').value
  rescue StandardError
    ''
  end

  def self.closed_office_message
    find_by(name: 'Pesan Kantor Tutup').description
  rescue StandardError
    ''
  end

  def self.open_days
    find_by(name: 'Hari Buka').description.split(',').map(&:downcase)
  rescue StandardError
    []
  end
end
