class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  has_many :recipients, foreign_key: 'recipient_id', class_name: 'Notification'
  has_many :actors, foreign_key: 'actor_id', class_name: 'Notification'
  has_many :notifications, foreign_key: :recipient_id
  has_one :user_detail, dependent: :destroy
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_many :submissions, dependent: :destroy
  has_many :intips, dependent: :destroy
  has_many :gps_plottings, dependent: :destroy
  has_many :workspaces, dependent: :destroy
  has_many :working_areas, dependent: :destroy

  validates :username, uniqueness: true
  validates :email, uniqueness: true

  scope :members, -> { joins(:roles).where('roles.name ILIKE ?', '%member%') }
  scope :admins, -> { joins(:roles).where('roles.name ILIKE ? OR roles.name ILIKE ?', '%admin%', '%kasubsi%') }

  after_create :set_working_area_user

  # kaminari
  paginates_per 10

  def set_working_area_user
    area = Area.find_by(is_default: true)
    WorkingArea.create(user_id: self.id, area_id: area.id)
  rescue
    Rails.logger.info '======> ERROR SET WORKING AREA <======'
  end

  def gps_with_workspace(workspace_id)
    return gps_plottings.where('sent_at IS NULL') unless workspace_id

    gps_plottings.where('sent_at IS NULL AND workspace_id = ?', workspace_id)
  end

  def intips_today
    intips.where(created_at: Date.today)
  end

  def gps_plottings_today
    gps_plottings.where(created_at: Date.today)
  end

  def self.process_api_login(user)
    current_user = find_by(username: user['username'].to_s.downcase)
    auth         = current_user.present? && current_user.valid_password?(user['password'])
    confirmed    = current_user.confirmed_at.present? rescue false

    return { status: 'FAILED', errors: ['Failed to login'] } unless (current_user.present? && auth )
    return { status: 'FAILED', errors: ['You have to confirm your email address before continuing.'] } unless confirmed

    area = current_user.working_areas.first.area rescue nil
    token = get_auth_token(current_user.id)
    unless area.nil?
      { status: 'SUCCESS', results: { token: "Bearer #{token}", working_area_name: area.name, working_area_id: area.area_id } }
    else
      { status: 'SUCCESS', results: { token: "Bearer #{token}", working_area_name: '', working_area_id: '' } }
    end
  end

  def self.process_api_register(user)
    new_user = new(username: user['username'], password: user['password'], email: user['email'])
    return { status: 'FAILED', errors: new_user.errors.full_messages } unless new_user.save

    UserDetail.create(fullname: user['fullname'], id_number: user['id_number'], user_id: new_user.id)
    UserRole.find_or_create_by(user_id: new_user.id, role_id: Role.member_sipilot_id) # set default user register has member role

    { status: 'SUCCESS', results: { message: 'You will receive an email with instructions for how to confirm your email address in a few minutes.' } }
  end

  def self.get_auth_token(user_id)
    Auth.issue({ user: user_id })
  end

  def email_required?
    false
  end

  def email_changed?
    false
  end

  def my_notifications
    Notification.where('recipient_id = ? AND read_at IS NULL', id).order('created_at desc').uniq { |val| val.notifiable_id }
  end

  def self.member_intip
    joins(:user_roles, :roles).where('roles.name ILIKE ?', "%member intip%")
  end

  def self.member_gps
    joins(:user_roles, :roles).where('roles.name ILIKE ?', "%member gps%")
  end

  def member_sipilot_id
    Role.where('name ILIKE ?', "%member sipilot%").first.try(:id)
  end

  def admin_validasi?
    roles.where('name ILIKE ?', '%admin validasi%').present?
  end

  def admin_tematik?
    roles.where('name ILIKE ?', '%admin tematik%').present?
  end

  def admin_buku_tanah?
    roles.where('name ILIKE ?', '%admin buku tanah%').present?
  end

  def admin_pola_ruang?
    roles.where('name ILIKE ?', '%admin pola ruang%').present?
  end

  def member_sipilot?
    roles.where('name ILIKE ?', '%member sipilot%').present?
  end

  def admin_intip?
    roles.where('name ILIKE ?', '%admin intip%').present?
  end

  def member_intip?
    roles.where('name ILIKE ?', '%member intip%').present?
  end

  def admin_gps?
    roles.where('name ILIKE ?', '%admin gps%').present?
  end

  def member_gps?
    roles.where('name ILIKE ?', '%member gps%').present?
  end

  def kasubsi_tematik?
    roles.where('name ILIKE ?', '%kasubsi tematik%').present?
  end

  def kasubsi_pola_ruang?
    roles.where('name ILIKE ?', '%kasubsi pola ruang%').present?
  end

  def kasubsi_pendaftaran?
    roles.where('name ILIKE ?', '%kasubsi pendaftaran%').present?
  end

  def super_admin?
    roles.where('name ILIKE ?', '%super admin%').present?
  end

  def role_name
    roles.first.name
  rescue StandardError
    ''
  end

  def role_id
    roles.first.id
  rescue StandardError
    ''
  end

  def fullname
    user_detail&.fullname
  end

  def id_number
    user_detail&.id_number
  end

  def address
    user_detail&.address
  end

  def phone_number
    user_detail&.phone_number
  end

  def profile_photo
    # Rails.application.routes.url_helpers.rails_blob_url(user_detail.profile_photo, only_path: true)
    user_detail.profile_photo
  rescue StandardError
    ''
  end
end
