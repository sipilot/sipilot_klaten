class Api::V1::UsersController < Api::BaseController
  skip_before_action :authenticate, except: [:profile, :logout, :role, :update_profile]

  def role
    api_success_response({ role: current_user_api.role_name })
  end

  def sent_code
    user = User.find_by(email: params[:email])
    return api_error_response(['Invalid email']) unless user.present?

    code = rand(1000...9999)
    user.update(reset_password_code: code)
    UserMailer.with(email: user.email, code: code).reset_password_code.deliver_now
    api_success_response({ message: 'Password reset code has been sent to your email.' })
  end

  def reset_password
    user = User.find_by(reset_password_code: params['code'], username: params[:username])
    return api_error_response(['Invalid password reset code.']) unless user

    user.reset_password_code = ''
    user.password = params['new_password']
    return api_success_response({ message: 'Success change password.' }) if user.save

    api_error_response(user.errors.full_messages)
  end

  def check_code
    user = User.find_by(email: params[:email])
    return api_success_response({ is_valid: false }) unless user

    valid_code = user.reset_password_code == params[:code]
    return api_success_response({ is_valid: false }) unless valid_code

    api_success_response({ is_valid: true })
  end

  def change_password
    valid = current_user_api.valid_password?(params['old_password'])
    if valid
      current_user_api.update(password: params['new_password'])
      api_success_response({ message: 'success change password' })
    else
      api_error_response(['Invalid password'])
    end
  end

  def login
    logged_in = User.process_api_login(JSON.parse(request.body.read))
    if logged_in[:status] == 'SUCCESS'
      api_success_response(logged_in[:results])
    else
      api_error_response(logged_in[:errors])
    end
  end

  def update_profile
    user = current_user_api
    user.email = params['email']
    user.username = params['username']
    if user.save
      user_detail = user.user_detail
      user_detail.address       = params['address']
      user_detail.fullname      = params['fullname']
      user_detail.id_number     = params['id_number']
      user_detail.phone_number  = params['phone_number']
      user_detail.profile_photo = params['profile_image']
      if user_detail.save
        response = { message: 'Success update profile' }
        api_success_response(response)
      else
        api_error_response(user_detail.errors.full_messages)
      end
    else
      api_error_response(user.errors.full_messages)
    end
  end

  def profile
    profile = {
      email: current_user_api.email,
      address: current_user_api.address,
      fullname: current_user_api.fullname,
      username: current_user_api.username,
      id_number: current_user_api.id_number,
      phone_number: current_user_api.phone_number,
      profile_photo: (url_for(current_user_api.profile_photo) rescue '')
    }
    api_success_response(profile)
  end

  def logout
    results = { message: 'Success log out.' }
    api_success_response(results)
  end

  def register
    patient_regist = User.process_api_register(JSON.parse(request.body.read))
    if patient_regist[:status] == 'SUCCESS'
      api_success_response(patient_regist[:results])
    else
      api_error_response(patient_regist[:errors])
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:fullname)
  end
end