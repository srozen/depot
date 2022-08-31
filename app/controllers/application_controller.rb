class ApplicationController < ActionController::Base
  before_action :authorize
  before_action :set_i18n_locale

  protected

  def authorize
    redirect_to login_url, notice: "Please log in" unless User.find_by(id: session[:user_id])
  end

  def set_i18n_locale
    if params[:locale]
      if I18n.available_locales.map(&:to_s).include?(params[:locale])
        I18n.locale = params[:locale]
      else
        flash.now[:notice] = "#{params[:locale]} translation not available"
        logger.error flash.now[:notice]
      end
    end
  end
end
