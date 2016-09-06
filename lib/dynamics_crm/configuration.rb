# Class for setting configuration options in this engine. See e.g.
# http://stackoverflow.com/questions/24104246/how-to-use-activesupportconfigurable-with-rails-engine
#
# To override default config values, for example in an initaliser, use e.g.:
#
#   DynamicsCRM.configure do |config|
#    config.timestamps_use_utc_plus_hour = true
#   end
#
# To access configuration settings use e.g.
#   DynamicsCRM.config.timestamps_use_utc_minus_hour
#
module DynamicsCRM
  class Configuration
    include ActiveSupport::Configurable

    # Set these to use a one hour difference, to the current system time in XML timestamps.
    # Can help overcome local  timezone issues that result in errors such as :
    #     s:Sender[a:InvalidSecurity] An error occurred when verifying security for the message.
    #
    config_accessor(:timestamps_use_utc_plus_hour)  { false }
    config_accessor(:timestamps_use_utc_minus_hour) { false }

  end

  def self.config
    @config ||= Configuration.new
  end

  def self.configure
    yield config
  end
end
