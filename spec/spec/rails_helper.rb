ENV['RAILS_ENV'] ||= 'test'
require_relative '../../spec_helper'
require File.expand_path('./../config/environment', File.dirname(__FILE__))
require 'rspec/rails'
require 'rails-api'
require 'sqlite3'

Dir[Rails.root.join('spec/support/**/*.rb')].sort.reverse.each { |f| require f }

RSpec.configure do |config|
  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  config.use_transactional_fixtures = false
  # config.fixture_path = "#{::Rails.root}/../fixtures"
  config.fixture_path = File.expand_path('fixtures', File.dirname(__FILE__))
  config.global_fixtures = :all

  config.before :each do
    User.current = nil
  end
end
