module FixtureHelpers
  module InstanceMethods

    def fixture(f)
      File.read(File.expand_path("../../fixtures/#{f}.xml", __FILE__))
    end

  end

end

RSpec.configure do |config|
  config.include FixtureHelpers::InstanceMethods
end
