ENV["RAILS_ENV"] ||= "test"
ENV["SECRET_KEY_BASE"] ||= "test-secret-key-base-value"
ENV["PAYMENTS_WEBHOOK_TOKEN"] ||= "test-webhook-token"
ENV["AI_PROVIDER"] ||= "mock"

require_relative "../config/environment"
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"
require "sidekiq/testing"

Sidekiq::Testing.fake!

Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |file| require file }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => error
  abort error.to_s.strip
end

RSpec.configure do |config|
  config.fixture_paths = []
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include FactoryBot::Syntax::Methods
  config.include ApiHelpers

  config.before do
    Sidekiq::Queues.clear_all if defined?(Sidekiq::Queues)
  end
end
