require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"

Bundler.require(*Rails.groups)

module Flowops
  class Application < Rails::Application
    config.load_defaults 7.2
    config.api_only = true
    config.autoload_lib(ignore: %w[assets tasks])
    config.time_zone = "UTC"
    config.active_record.schema_format = :ruby

    config.generators do |generator|
      generator.test_framework :rspec
      generator.helper false
      generator.assets false
    end
  end
end
