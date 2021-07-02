require 'georuby'
require 'geo_ruby/shp'        # Shapefile
require 'rgeo/shapefile'

class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :check_open_office
  before_action :set_role

  include GeoRuby::SimpleFeatures

  add_flash_types :info, :errors, :warning

  def after_sign_in_path_for(resource)
    role = current_user.role_name.downcase

    path ||= '/superadmin' if ['super admin'].include? role
    path ||= '/gps/admin' || gps_admin_path if ['admin gps'].include? role
    path ||= '/gps/member' || gps_member_path if ['member gps'].include? role
    path ||= '/dashboards/member' || dashboards_member_path if ['member sipilot'].include? role
    path ||= '/dashboards/admin' || dashboards_admin_path if ['admin validasi', 'admin buku tanah', 'admin pola ruang'].include? role
    path ||= '/dashboards/kasubsi' || dashboards_kasubsi_path if ['kasubsi tematik', 'kasubsi pola ruang', 'kasubsi pendaftaran'].include? role
    path
  end

  def set_role
    @role = current_user.role_name.downcase rescue ''
  end

  def set_pagination_state
    page ||= (10 * (params[:page].to_i - 1)) if params[:page].to_i >= 2
    page ||= 1

    @start_from ||= page + 1 if page >= 10
    @start_from ||= page
    @start_from
  end

  def submission_ses
    session[:submission_ids] ||= []
  end

  def check_open_office
    close_hour = Setting.close_hour
    open_days = Setting.open_days
    hour_now = Time.now.strftime('%H:%M')
    day_now = Date.today.strftime('%A').downcase

    @is_closed ||= true if (hour_now == close_hour || hour_now >= close_hour)
    @is_closed ||= true if !open_days.include?(day_now)
    @is_closed ||= false

    @is_closed
  end

  def submission_set
    if params['type'] == 'set_all'
      session[:submission_ids] = session[:all_submission_ids]
      session[:is_check_all] = true

      return
    end

    if params['type'] == 'remove_all'
      session[:submission_ids] = []
      session[:is_check_all] = false

      return
    end

    if submission_ses.include?(params['id'])
      submission_ses.delete(params['id'])
    else
      submission_ses << params['id']
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :id_number, :fullname])
  end
end
