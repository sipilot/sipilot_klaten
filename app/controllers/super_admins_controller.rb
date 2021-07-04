class SuperAdminsController < ApplicationController
  layout 'dashboards'

  before_action :find_user, only: %i[edit_member edit_admin]
  before_action :destroy_user, only: %i[destroy_member destroy_admin]
  before_action :set_user, only: %i[process_create_member process_create_admin]

  def index; end

  def validations
    @search = Submission.list_validation.ransack(params[:q])
    @submissions = @search.result.includes(:sub_district, :village, :hak_type).page params[:page]
  end

  def validation_detail
    @submission = Submission.find_by(id: params[:id])
    return redirect_to superadmin_validasi_path if @submission.nil?
  end

  def space_patterns
    @search = Submission.list_space_pattern.ransack(params[:q])
    @submissions = @search.result.includes(:sub_district, :village, :hak_type).page params[:page]
  end

  def space_pattern_detail
    @submission = Submission.find_by(id: params[:id])
    return redirect_to superadmin_pola_ruang_path if @submission.nil?
  end

  def list_member
    @search_params = params[:q][:username_or_email_cont] rescue ''
    @search = User.members.ransack(params[:q])
    @members = @search.result.order('username asc').page(params[:page]).per(params[:per])

    session[:all_submission_ids] = @search.result.pluck(:id).map(&:to_s)

    p '=====SUPER ADMIN - LIST MEMBER======='
    p session[:all_submission_ids]
    p '============'
  end

  def edit_member
    @member = @user
  end

  def process_update_member
    user = User.find(user_params[:id])
    user.update(user_params.except(:user_id, :password))
    user.update(password: user_params['password']) if user_params[:password].present?
    user.user_detail.update(user_details_params)

    flash[:notice] = 'Berhasil memperbaharui member.'
    redirect_to superadmin_member_path
  end

  def destroy_member
    flash[:notice] = 'Berhasil menghapus member.'
    redirect_to superadmin_member_path
  end

  def destroy_all_member
    submissions = User.where(id: submission_ses)
    submissions.destroy_all

    session[:submission_ids] = []
    session[:is_check_all] = false
    flash[:notice] = 'Berhasil menghapus member.'
    redirect_to superadmin_member_path
  end

  def process_create_member
    if @user.save
      @user.skip_confirmation!
      UserDetail.create(user_id: @user.id, fullname: params['fullname'], phone_number: params['phone_number'])
      UserRole.create(user_id: @user.id, role_id: params['role_id'])

      flash[:notice] = 'Berhasil menambahkan member.'
      redirect_to superadmin_member_path
    else
      flash[:errors] = @user.errors.full_messages
      redirect_to sa_new_member_path
    end
  end

  def new_member
    @roles = Role.members
  end

  def list_admin
    @search = User.admins.ransack(params[:q])
    @admins = @search.result.order('username asc').page(params[:page]).per(params[:per])
  end

  def new_admin
    @roles = Role.admins
  end

  def process_create_admin
    if @user.save
      @user.skip_confirmation!
      UserDetail.create(user_id: @user.id, fullname: params['fullname'], phone_number: params['phone_number'])
      UserRole.create(user_id: @user.id, role_id: params['role_id'])

      flash[:notice] = 'Berhasil menambahkan admin.'
      redirect_to superadmin_admin_path
    else
      flash[:errors] = @user.errors.full_messages
      redirect_to sa_new_admin_path
    end
  end

  def destroy_admin
    flash[:notice] = 'Berhasil menghapus admin.'
    redirect_to superadmin_admin_path
  end

  def process_update_admin
    user = User.find(user_params[:id])
    user.update(user_params.except(:user_id, :password))
    user.update(password: user_params['password']) if user_params[:password].present?
    user.user_detail.update(user_details_params)

    flash[:notice] = 'Berhasil memperbaharui admin.'
    redirect_to superadmin_admin_path
  end

  def edit_admin
    @admin = @user
  end

  def settings
    @close_hour = Setting.close_hour
    @open_days = Setting.open_days
    @open_days.each { |value| instance_variable_set("@#{value}", value) }
    @days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ]
  end

  def update_settings
    action_type = params['button']
    case action_type
    when 'btn_close_time'
      setting = Setting.find_or_initialize_by(name: 'Jam Tutup')
      setting.update_attributes(
        value: params['close_time']
      )
    when 'btn_open_days'
      days = params['days'].keys.join(',') rescue ''
      setting = Setting.find_or_initialize_by(name: 'Hari Buka')
      setting.update_attributes(
        description: days
      )
    else
      puts 'Wrong setting type.'
    end
  end

  private

  def set_user
    @user = User.new(create_user_params)
  end

  def find_user
    @user = User.find_by(id: params[:id])
  end

  def destroy_user
    user = User.find(params[:id])
    user.destroy
  end

  def create_user_params
    params.permit(
      :email,
      :username,
      :password
    )
  end

  def user_params
    params.require(:user).permit(
      :id,
      :email,
      :username,
      :password
    )
  end

  def user_details_params
    params.require(:user).permit(
      :fullname,
      :phone_number
    )
  end
end
