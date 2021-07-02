class CartsController < ApplicationController
  layout 'application'

  def index
    if current_user_api
      @submission_recaps = current_user_api.submissions
      @carts = @submission_recaps.group(:submission_status).group_by_month(:created_at, format: "%B").count
    else
      @submission_recaps = nil
    end
  end

  def token
    params['token'].scan(/Bearer (.*)$/).flatten.last
  end

  def auth
    Auth.decode(token)
  end

  def current_user_api
    user = User.find_by(id: auth['user'])
    @current_user_api = user
  rescue StandardError
    nil
  end
end
