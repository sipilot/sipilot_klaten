class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def counter; end

  def profile
    @user = current_user
    @notifications = current_user.my_notifications
  end

  def update_profile
    current_user.update(user_params)
    current_user.user_detail.update(user_details_params)
    flash[:notice] = 'Berhasil memperbaharui data profil.'
    redirect_to dashboards_profile_path
  end

  def update_password
    valid = current_user.valid_password?(password_params['current_password'])
    if valid && (password_params['new_password'].length >= 6) && (password_params['new_password'] == password_params['confirmation_password'])
      current_user.update(password: password_params['new_password'])
      sign_in(current_user, bypass: true)
      flash[:notice] = 'Berhasil memperbaharui password.'
      redirect_to dashboards_profile_path
    else
      flash[:errors] = ['Password baru yang anda masukkan tidak valid.']
      redirect_to dashboards_profile_path
    end
  end

  private

  def user_params
    params.require(:user).permit(:email)
  end

  def user_details_params
    params.require(:user).permit(
      :address,
      :fullname,
      :username,
      :id_number,
      :phone_number
    )
  end

  def password_params
    params.require(:pass).permit(
      :new_password,
      :current_password,
      :confirmation_password
    )
  end
end
