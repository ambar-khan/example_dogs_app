class ApplicationController < ActionController::Base

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

  def index
    @articles = HTTP.get("http://newsapi.org/v2/everything?q=apple&from=2020-11-24&to=2020-11-24&sortBy=popularity&apiKey=#{Rails.application.credentials.news_api[:api_key]}").parse
    render 'index.json.jb'
  end


end
