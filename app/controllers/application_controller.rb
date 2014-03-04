class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # has_mobile_fu
  helper_method :is_mobile_device?, :production?

  def is_mobile_device?
    false
  end

  def after_sign_in_path_for(resource)
    groups_path
  end

  def production?
    @is_production ||= ENV['RAILS_ENV'] == 'production'
  end
end
