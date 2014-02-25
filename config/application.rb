require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(:default, Rails.env)

module Redirectme
  class Application < Rails::Application
    config.i18n.default_locale = :ru

    config.autoload_paths += [ Rails.root.join('app', 'rack') ]

    config.middleware.insert_before "Rack::Sendfile", "RedirectApp"

    config.cache_store = :redis_store, 'redis://localhost:6379/1/rm'
    config.session_store :redis_store, 'redis://localhost:6379/1/rm_sessions'
  end
end
