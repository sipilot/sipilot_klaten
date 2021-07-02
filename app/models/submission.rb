class Submission < ApplicationRecord
  belongs_to :sub_district
  belongs_to :hak_type
  belongs_to :service
  belongs_to :village
  belongs_to :user

  has_many :notifications, as: :notifiable
  has_many :submission_files, as: :submissionable
  has_many :notes, dependent: :destroy

  before_create :set_submission_date
  before_create :set_submission_code
  before_create :set_status

  scope :total_space_pattern, -> { where(service_id: Service.space_pattern_id).count }
  scope :total_validation, -> { where(service_id: Service.validation_id).count }

  scope :list_space_pattern, -> { where(service_id: Service.space_pattern_id).order(created_at: :desc) }
  scope :list_validation, -> { where(service_id: Service.validation_id).order(created_at: :desc) }

  scope :total_revisions_validation, -> { where('submission_status = ? OR land_book_status = ?', 'revisi', 'revisi').count }
  scope :total_revisions_space_pattern, -> { where(space_pattern_status: 'revisi').count }

  scope :total_process_validation, -> { where('submission_status = ? OR land_book_status = ? OR kasubsi_registration_status = ? OR kasubsi_tematik_status = ?', 'proses', 'proses', 'proses', 'proses').count }
  scope :total_process_space_pattern, -> { where('space_pattern_status = ? OR kasubsi_space_pattern_status = ?', 'proses', 'proses').count }

  scope :total_done_validation, -> { where(submission_status: 'selesai', land_book_status: 'selesai', kasubsi_registration_status: 'selesai', kasubsi_tematik_status: 'selesai').count }
  scope :total_done_space_pattern, -> { where(space_pattern_status: 'selesai', kasubsi_space_pattern_status: 'selesai').count }

  enum act_for: {
    'Diri Sendiri' => 1,
    'Kuasa' => 2
  }
  enum admin_referral: {
    'CAGAR BUDAYA' => 1,
    'PERTAHANAN KEAMANAN (HANKAM)' => 2,
    'HUTAN LINDUNG (HL)' => 3,
    'HOLTIKULTURA' => 4,
    'HUTAN PRODUKSI (HP)' => 5,
    'HUTAN PRODUKSI TERBATAS (HPT)' => 6,
    'HUTAN RAKYAT' => 7,
    'INDUSTRI' => 8,
    'KAWASAN RAWAN BENCANA ALAM GEOLOGI' => 9,
    'PARIWISATA' => 10,
    'PERIKANAN' => 11,
    'PERKEBUNAN' => 12,
    'PERMUKIMAN' => 13,
    'PERTAMBANGAN' => 14,
    'PERTANIAN TANAMAN PANGAN' => 15,
    'PETERNAKAN' => 16,
    'RTH' => 17,
    'SEMPADAN MATA AIR' => 18,
    'SEMPADAN REL KERETA API' => 19,
    'SEMPADAN SUNGAI' => 20,
    'SEMPADAN WADUK' => 21,
    'TNGM' => 22
  }

  validate :hak_number_exist, on: :create

  # kaminari
  paginates_per 10

  # ransack
  ransacker :created_at do
    Arel.sql('date(created_at)')
  end

  def land_book_images
    submission_files.where(file_type: 'land_book')
  end

  def measuring_letter_images
    submission_files.where(file_type: 'measuring_letter')
  end

  def note_admin_validasi
    notes.where(note_type: 'Admin Validasi', name: 'Ambil').first.description
  rescue StandardError
    nil
  end

  def note_admin_buku_tanah
    notes.where(note_type: 'Admin Buku Tanah', name: 'Ambil').first.description
  rescue StandardError
    nil
  end

  def note_admin_pola_ruang
    notes.where(note_type: 'Admin Pola Ruang', name: 'Ambil').first.description
  rescue StandardError
    nil
  end

  def has_nib?
    !nib.nil? && !nib.empty? && nib.to_s.length.positive?
  end

  # submission_status
  # - proses
  # - revisi
  # - selesai
  # - sudah direvisi

  def self.admin_applications(role)
    submissions ||= where(submission_status: ['proses', 'sudah direvisi'], service_id: Service.validation_id).order(created_at: :desc)       if role == 'admin validasi'
    submissions ||= where(land_book_status: ['proses', 'sudah direvisi'], service_id: Service.validation_id).order(created_at: :desc)        if role == 'admin buku tanah'
    submissions ||= where(space_pattern_status: ['proses', 'sudah direvisi'], service_id: Service.space_pattern_id).order(created_at: :desc) if role == 'admin pola ruang'
    submissions
  end

  def self.admin_revisions(role)
    submissions ||= where(submission_status: ['revisi'], service_id: Service.validation_id).order(created_at: :desc)       if role == 'admin validasi'
    submissions ||= where(land_book_status: ['revisi'], service_id: Service.validation_id).order(created_at: :desc)        if role == 'admin buku tanah'
    submissions ||= where(space_pattern_status: ['revisi'], service_id: Service.space_pattern_id).order(created_at: :desc) if role == 'admin pola ruang'
    submissions
  end

  def self.admin_counters(role)
    submissions ||= where(submission_status: 'selesai', service_id: Service.validation_id).order(created_at: :desc)       if role == 'admin validasi'
    submissions ||= where(land_book_status: 'selesai', service_id: Service.validation_id).order(created_at: :desc)        if role == 'admin buku tanah'
    submissions ||= where(space_pattern_status: 'selesai', service_id: Service.space_pattern_id).order(created_at: :desc) if role == 'admin pola ruang'
    submissions
  end

  def self.submission_todays(role)
    submissions ||= where(submission_status: ['proses', 'sudah direvisi'], submission_date: Time.now, service_id: Service.validation_id).order(created_at: :desc)        if role == 'admin validasi'
    submissions ||= where(land_book_status: ['proses', 'sudah direvisi'], submission_date: Time.now, service_id: Service.validation_id).order(created_at: :desc)         if role == 'admin buku tanah'
    submissions ||= where(space_pattern_status: ['proses', 'sudah direvisi'], submission_date: Time.now, service_id: Service.space_pattern_id).order(created_at: :desc)  if role == 'admin pola ruang'
    submissions
  end

  def self.kasubsi_submission_todays(role)
    submissions ||= where('submission_status = ? AND kasubsi_tematik_status != ? AND service_id = ?', 'selesai', 'selesai', Service.validation_id).order(created_at: :desc)             if role == 'kasubsi tematik'
    submissions ||= where('land_book_status = ? AND kasubsi_registration_status != ? AND service_id = ?', 'selesai', 'selesai', Service.validation_id).order(created_at: :desc)         if role == 'kasubsi pendaftaran'
    submissions ||= where('space_pattern_status = ? AND kasubsi_space_pattern_status != ? AND service_id = ?', 'selesai', 'selesai', Service.space_pattern_id).order(created_at: :desc) if role == 'kasubsi pola ruang'
    submissions
  end

  def self.kasubsi_submission_report(role)
    submissions ||= where('submission_status = ? AND kasubsi_tematik_status = ? AND service_id = ?', 'selesai', 'selesai', Service.validation_id).order(created_at: :desc)             if role == 'kasubsi tematik'
    submissions ||= where('land_book_status = ? AND kasubsi_registration_status = ? AND service_id = ?', 'selesai', 'selesai', Service.validation_id).order(created_at: :desc)         if role == 'kasubsi pendaftaran'
    submissions ||= where('space_pattern_status = ? AND kasubsi_space_pattern_status = ? AND service_id = ?', 'selesai', 'selesai', Service.space_pattern_id).order(created_at: :desc) if role == 'kasubsi pola ruang'
    submissions
  end

  def self.done_validation_spatials
    where(submission_status: 'selesai',kasubsi_tematik_status: 'selesai', service_id: Service.validation_id, created_at: 1.week.ago..Date.today).order(created_at: :desc)
  end

  def self.done_validation_land_book
    where(land_book_status: 'selesai',kasubsi_registration_status: 'selesai', service_id: Service.validation_id, created_at: 1.week.ago..Date.today).order(created_at: :desc)
  end

  def self.done_space_pattern
    where(space_pattern_status: 'selesai', kasubsi_space_pattern_status: 'selesai', service_id: Service.space_pattern_id, created_at: 1.week.ago..Date.today).order(created_at: :desc)
  end

  def notif_type
    type ||= 'validation'     if validation_service?
    type ||= 'space_pattern'  if space_pattern_service?
    type
  end

  def validation_service?
    service.name == 'Validasi'
  end

  def space_pattern_service?
    service.name == 'Pola Ruang'
  end

  def service_name
    service.name
  rescue StandardError
    ''
  end

  def date
    created_at.strftime('%d %B %Y')
  end

  def date_completion
    date_of_completion.strftime('%d %B %Y')
  rescue StandardError
    ''
  end

  def set_submission_date
    self.submission_date = Time.now
  end

  def hak_name
    hak_type.name
  end

  def village_name
    village.name
  rescue StandardError
    ''
  end

  def sub_district_name
    sub_district.name
  rescue StandardError
    ''
  end

  def image_id_number
    submission_files.where(file_type: 'id_number').first.image
  rescue StandardError
    nil
  end

  def image_authority_letter
    submission_files.where(file_type: 'authority_letter').first.image
  rescue StandardError
    nil
  end

  def image_measuring_letter
    submission_files.where(file_type: 'measuring_letter')
  rescue StandardError
    nil
  end

  def image_land_book
    submission_files.where(file_type: 'land_book')
  rescue StandardError
    nil
  end

  def set_submission_code
    service_type = self.service.name.downcase
    latest_id ||= Submission.where("submission_code ilike ?", "%PR%").order('submission_code').pluck('registration_code').last.to_i if service_type == 'pola ruang'
    latest_id ||= Submission.where("submission_code ilike ?", "%VAL%").order('submission_code').pluck('registration_code').last.to_i if service_type == 'validasi'
    latest_id ||= 0

    incremented = (latest_id + 1).to_s
    while incremented.length < 5 do
      incremented.prepend('0')
    end

    code ||= "VAL-#{incremented}"  if service.name == 'Validasi'
    code ||= "PR-#{incremented}"   if service.name == 'Pola Ruang'
    code ||= ''

    self.registration_code  = incremented
    self.submission_code    = code
  end

  def set_status
    self.kasubsi_space_pattern_status = 'proses'
    self.kasubsi_registration_status = 'proses'
    self.kasubsi_tematik_status = 'proses'
    self.space_pattern_status = 'proses'
    self.submission_status = 'proses'
    self.land_book_status = 'proses'
    self.kasubsi_status = 'proses'
  end

  def self.process_submission_image(submission, land_books, measuring_letters, id_number, authority_letter)
    submission.submission_files.create(image: id_number, file_type: 'id_number')

    submission.submission_files.create(image: authority_letter, file_type: 'authority_letter') unless authority_letter.nil?

    land_books.each do |lb|
      submission.submission_files.create(image: lb, file_type: 'land_book')
    end

    measuring_letters.each do |ml|
      submission.submission_files.create(image: ml, file_type: 'measuring_letter')
    end
  end

  def process_submission_image_nested(land_books, measuring_letters, id_number, authority_letter)
    self.submission_files.create(image: id_number, file_type: 'id_number', description: 'ktp')
    self.submission_files.create(image: authority_letter, file_type: 'authority_letter', description: 'authority_letter') unless authority_letter.nil?

    land_books.each {|key, value| self.submission_files.create(image: value, description: key, file_type: 'land_book')}
    measuring_letters.each {|key, value| self.submission_files.create(image: value, description: key, file_type: 'measuring_letter')}
  end

  # NOTE : this method need to optimize!
  def process_submission_image_update(land_books, measuring_letters, id_number, authority_letter)
    self.submission_files.find_by(file_type: 'id_number').update(image: id_number) unless id_number.nil?
    self.submission_files.find_by(file_type: 'authority_letter').update(image: authority_letter) unless authority_letter.nil?

    unless land_books.nil?
      land_books.each do |lb|
        submission_file = self.submission_files.find_by(file_type: 'land_book', description: lb[0])
        if submission_file
          submission_file.update(image: lb[-1])
        else
          self.submission_files.create(file_type: 'land_book', description: lb[0], image: lb[-1])
        end
      end
    end

    unless measuring_letters.nil?
      measuring_letters.each do |lb|
        submission_file = self.submission_files.find_by(file_type: 'measuring_letter', description: lb[0])
        if submission_file
          submission_file.update(image: lb[-1])
        else
          self.submission_files.create(file_type: 'measuring_letter', description: lb[0], image: lb[-1])
        end
      end
    end
  end

  def submission_params
    params.permit(:on_behalf, :act_for, :hak_number, :hay_type, :land_address, :fullname, :lattitude, :longitude)
  end

  def hak_number_exist
    return if self.service.name.downcase == 'pola ruang'

    submission = Submission.find_by(hak_number: self.hak_number, hak_type: self.hak_type, village: self.village)
    return unless submission.present?

    errors.add(:nomor_hak, 'sudah terdaftar pada jenis sertipikat yang anda pilih.')
  end
end
