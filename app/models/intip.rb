class Intip < ApplicationRecord
  belongs_to :user
  belongs_to :village
  belongs_to :sub_district
  has_many :notifications, as: :notifiable
  belongs_to :workspace, optional: true
  belongs_to :alas_type, optional: true
  belongs_to :hak_type

  enum status: { 'Proses' => 1, 'Diterima' => 2 }
  enum certificate_status: {
    'Sudah Sertipikat' => 1,
    'Belum Sertipikat' => 2
  }

  has_one_attached :image

  # validastes
  validates :nui, presence: { message: 'NUI wajib diisi' }
  validates :name, presence: { message: 'Nama Instansi wajib diisi' }
  # validates :hak_type, presence: { message: 'Tipe Hak wajib diisi' }
  validates :date, presence: { message: 'Tanggal wajib diisi' }
  validates :time_range, presence: { message: 'Nama Instansi wajib diisi' }
  validates :land_control, presence: { message: 'Penguasaan Tanah wajib diisi' }
  validates :land_allocation, presence: { message: 'Peruntukan Tanah wajib diisi' }
  validates :land_use, presence: { message: 'Penggunaan Tanah wajib diisi' }
  validates :land_utilization, presence: { message: 'Pemanfaatan Tanah wajib diisi' }
  validates :land_size, presence: { message: 'Luas Tanah (M2) wajib diisi' }
  validates :image, presence: { message: 'Gambar wajib diisi' }
  validate :hak_number_exist
  validate :nui_exist_in_village
  validate :nib_exist_in_village

  before_create :set_created_at

  # kaminari
  paginates_per 10

  # ransack
  ransacker :created_at do
    Arel.sql('date(created_at)')
  end

  def sub_district_name
    workspace.sub_district.try(:name)
  rescue StandardError
    ''
  end

  def village_name
    workspace.village.try(:name)
  rescue StandardError
    ''
  end

  def set_created_at
    self.created_at = Date.today
  end

  def hak_number_exist
    intip = Intip.find_by(hak_number: self.hak_number, hak_type: self.hak_type)

    return unless intip.present?

    errors.add(:nomor_hak, 'sudah terdaftar pada jenis sertipikat yang anda pilih.')
  end

  def nui_exist_in_village
    intip = Intip.find_by(nui: self.nui, village: self.village)

    return unless intip.present? ||self.nui.nil? || self.nui.empty?

    errors.add(:nui, 'sudah terdaftar pada desa yang anda pilih.')
  end

  def nib_exist_in_village
    intip = Intip.find_by(nib: self.nib, village: self.village)

    return unless intip.present? ||self.nib.nil? || self.nib.empty?

    errors.add(:nib, 'sudah terdaftar pada desa yang anda pilih.')
  end

  def alas_name
    alas_type.name rescue ''
  end

  def hak_name
    hak_type.name rescue ''
  end
end
