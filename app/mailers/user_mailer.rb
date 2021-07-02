class UserMailer < ApplicationMailer
  default from: 'support@sipilot.id'

  def reset_password_code
    @email  = params[:email]
    @code   = params[:code]
    mail(to: @email, subject: 'Reset Password Code')
  end
end
