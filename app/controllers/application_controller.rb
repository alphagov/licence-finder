class ApplicationController < ActionController::Base
  include Slimmer::Template

  slimmer_template 'wrapper'

  if ENV["BASIC_AUTH_USERNAME"]
    http_basic_authenticate_with(
      name: ENV.fetch("BASIC_AUTH_USERNAME"),
      password: ENV.fetch("BASIC_AUTH_PASSWORD")
    )
  end

protected

  rescue_from GdsApi::TimedOutException, with: :error_503

  def error_503(exception = nil)
    error(503, exception)
  end

  def error(status_code, exception = nil)
    GovukError.notify(exception)

    render status: status_code, text: "#{status_code} error"
  end

  def set_expiry(duration = 30.minutes)
    unless Rails.env.development?
      expires_in(duration, public: true)
    end
  end
end
