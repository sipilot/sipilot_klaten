class Role < ApplicationRecord
  validates :name, uniqueness: true
  validates :name, presence: true

  has_many :user_roles
  has_many :users, through: :user_roles

  scope :members, -> { where('name ILIKE ?', '%member%') }
  scope :admins, -> { where('name ILIKE ? OR name ILIKE ?', '%admin%', '%kasubsi%') }

  def self.kasubsi_pendaftaran_id
    where('name ILIKE ?', '%kasubsi pendaftaran%').first.try(:id)
  end

  def self.kasubsi_pola_ruang_id
    where('name ILIKE ?', '%kasubsi pola ruang%').first.try(:id)
  end

  def self.kasubsi_tematik_id
    where('name ILIKE ?', '%kasubsi tematik%').first.try(:id)
  end

  def self.admin_buku_tanah_id
    where('name ILIKE ?', '%admin buku tanah%').first.try(:id)
  end

  def self.admin_pola_ruang_id
    where('name ILIKE ?', '%admin pola ruang%').first.try(:id)
  end

  def self.member_sipilot_id
    where('name ILIKE ?', '%member sipilot%').first.try(:id)
  end

  def self.admin_validasi_id
    where('name ILIKE ?', '%admin_validasi%').first.try(:id)
  end

  def self.admin_tematik_id
    where('name ILIKE ?', '%admin tematik%').first.try(:id)
  end

  def self.admin_intip_id
    where('name ILIKE ?', '%admin intip%').first.try(:id)
  end

  def self.member_intip_id
    where('name ILIKE ?', '%member intip%').first.try(:id)
  end

  def self.member_gps_id
    where('name ILIKE ?', '%member gps%').first.try(:id)
  end

  def self.admin_gps_id
    where('name ILIKE ?', '%admin gps%').first.try(:id)
  end
end
