require 'simplecov'
require 'pry'
SimpleCov.start do
	add_filter "/vendor/"
end

require 'bundler/setup'
Bundler.require :default, :test

RSpec.configure do |config|
  config.order = 'random'
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each {|f| require f}
