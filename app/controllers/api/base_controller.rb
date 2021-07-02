class Api::BaseController < ApplicationController
  respond_to :json
  before_action :authenticate

  def api_success_response(results, status=:ok)
    render json: {
      status: 'SUCCESS',
      results: results,
      errors: []
    }, status: status
  end

  def api_error_response(errors, status=:unprocessable_entity)
    render json: {
      status: 'FAILED',
      results: [],
      errors: errors
    }, status: status
  end

  def logged_in?
    !!current_user_api
  end

  def authenticate
    response = ['Unauthorized access']
    api_error_response(response, 401) unless logged_in?
  end

  def token
    request.env['HTTP_AUTHORIZATION'].scan(/Bearer (.*)$/).flatten.last
  end

  def auth
    Auth.decode(token)
  end

  def auth_present?
    !!request.env.fetch('HTTP_AUTHORIZATION', '').scan(/Bearer/).flatten.first
  end

  def current_user_api
    user = User.find_by(id: auth['user'])
    @current_user_api = user
  rescue StandardError
    nil
  end
end
