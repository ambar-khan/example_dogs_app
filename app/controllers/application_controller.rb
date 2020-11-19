class ApplicationController < ActionController::Base
  # before_action :require_login

  # private

  # # def require_login
  # #   unless logged_in?
  # #     flash[:error] = "You must be logged in to create a new dog"
  # #     # redirect_to new_login_url # halts request cycle
  # #   end
  # # end

  protect_from_forgery with: :exception, if: -> { request.format.html? }

  def current_user
    auth_headers = request.headers["Authorization"]
    if auth_headers.present? && auth_headers[/(?<=\A(Bearer ))\S+\z/]
      token = auth_headers[/(?<=\A(Bearer ))\S+\z/]
      begin
        decoded_token = JWT.decode(
          token,
          Rails.application.credentials.fetch(:secret_key_base),
          true,
          { algorithm: "HS256" }
        )
        User.find_by(id: decoded_token[0]["user_id"])
      rescue JWT::ExpiredSignature
        nil
      end
    end
  end

  helper_method :current_user

  def authenticate_user
    unless current_user
      render json: {}, status: :unauthorized
    end
  end

end
