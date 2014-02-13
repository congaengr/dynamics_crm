require "mscrm/soap/version"
require "mscrm/authentication"

module Mscrm
  module Soap

	class Client
		attr_accessor :client

		def initialize(organization_name)
			@client = Savon.client(wsdl: "https://#{organization_name}.api.crm.dynamics.com/XRMServices/2011/Organization.svc?wsdl=wsdl0")
		end

	end
  end
end
