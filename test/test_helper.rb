ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Disable Rack::Attack by default so throttling doesn't interfere with other tests
    setup { Rack::Attack.enabled = false }
  end
end

class ActionDispatch::IntegrationTest
  parallelize(workers: 1)
end
