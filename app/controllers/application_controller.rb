class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  rescue_from ApplicationInteractor::Error, with: :render_unprocessable_entity_from_interactor

  before_action :require_current_user

  def current_user
    @current_user ||= User.find_by(id: request.headers["X-User-Id"])
  end

  def require_current_user
    render status: :forbidden unless current_user
  end

  def render_unprocessable_entity_from_interactor(error)
    render json: { errors: [ { code: error.code, message: error.message } ] }, status: :unprocessable_entity
  end
end
