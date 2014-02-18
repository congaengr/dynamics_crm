require "mscrm/soap/version"
require "mscrm/soap/message_builder"
require "mscrm/soap/model/fault"
require "mscrm/soap/model/attributes"
require "mscrm/soap/model/column_set"
require "mscrm/soap/model/entity"
require "mscrm/soap/model/result"
require "mscrm/soap/model/retrieve_result"
require "mscrm/soap/model/create_result"
require "mscrm/soap/model/execute_result"

require "rexml/document"
require 'savon'
require 'curl'

# SOAP Only Walk through
# http://code.msdn.microsoft.com/CRM-Online-2011-WebServices-14913a16
#
# PHP starting point: 
# http://crmtroubleshoot.blogspot.com.au/2013/07/dynamics-crm-2011-php-and-soap-using.html
# 
# OCP: Open Commerce Platform
# https://community.dynamics.com/crm/b/crmgirishraja/archive/2012/09/04/authentication-with-dynamics-crm-online-on-ocp-office-365.aspx
module Mscrm
  module Soap

    class Client
      extend Forwardable

      include MessageBuilder

      # The Login URL and Region are located in the client's Organization WSDL.
      # https://tinderboxdev.api.crm.dynamics.com/XRMServices/2011/Organization.svc?wsdl=wsdl0
      # 
      # Login URL: Policy -> Issuer -> Address
      # Region: SecureTokenService -> AppliesTo
      LOGIN_URL = "https://login.microsoftonline.com/RST2.srf"
      REGION = 'urn:crmna:dynamics.com';

      def_delegators :@savon, :operations, :call

      def initialize(config={organization_name: nil, endpoint: nil, hostname: nil})
        service = "/XRMServices/2011/Organization.svc"
        @savon = Savon.client(
          endpoint: "https://#{config[:organization_name]}.api.crm.dynamics.com#{service}",
          wsdl: "https://#{config[:organization_name]}.api.crm.dynamics.com#{service}?wsdl=wsdl0"
        )

        @hostname = config[:hostname] || "tinderboxdev.api.crm.dynamics.com"
        @organization_endpoint = "https://#{@hostname}/XRMServices/2011/Organization.svc"
      end

      def authenticate_user(username, password)

        @username = username
        @password = password

        soap_response = post(LOGIN_URL, build_ocp_request(username, password))

        document = REXML::Document.new(soap_response)

        cipher_values = document.get_elements("//CipherValue")

        if cipher_values && cipher_values.length > 0
          @security_token0 = cipher_values[0].text
          @security_token1 = cipher_values[1].text
          # Use local-name() to ignore namespace.
          @key_identifier = document.get_elements("//[local-name() = 'KeyIdentifier']").first.text
        else
          raise RuntimeError.new(soap_response)
        end
      end

      # These are all the operations defined by the Dynamics WSDL.
      # Tag name case MATTERS!

      def create(entity_name, attributes)

        entity = Model::Entity.new(entity_name)
        entity.attributes = Model::Attributes.new(attributes)

        xml_response = post(@organization_endpoint, create_request(entity))
        return Model::CreateResult.new(xml_response)
      end

      # http://crmtroubleshoot.blogspot.com.au/2013/07/dynamics-crm-2011-php-and-soap-calls.html
      def retrieve(entity_name, guid, columns=[])

        column_set = Model::ColumnSet.new(columns)
        request = retrieve_request(entity_name, guid, column_set)

        xml_response = post(@organization_endpoint, request)
        return Model::RetrieveResult.new(xml_response)
      end

      def retrieve_multiple
      end

      # Update entity attributes
      def update(entity_name, guid, attributes)

        entity = Model::Entity.new(entity_name)
        entity.id = guid
        entity.attributes = Model::Attributes.new(attributes)

        request = update_request(entity)
        xml_response = post(@organization_endpoint, request)
        return Model::UpdateResult.new(xml_response)
      end 

      def delete(entity_name, guid)
        request = delete_request(entity_name, guid)

        xml_response = post(@organization_endpoint, request)
        return Model::DeleteResult.new(xml_response)
      end

      def execute(action, parameters={})
        request = execute_request(action, parameters)
        xml_response = post(@organization_endpoint, request)
        return Model::ExecuteResult.new(xml_response)
      end

      def associate
      end

      def disassociate
      end

      def retrieve_all_entities
        self.execute("RetrieveAllEntities", {
          EntityFilters: "Entity",
          RetrieveAsIfPublished: true
          })
      end

      def who_am_i
        self.execute('WhoAmI')
      end

      protected

      def post(url, request)

        puts "REQUEST"
        puts request

        #"POST " . "/Organization.svc" . " HTTP/1.1",
        #"Host: tinderboxdev.api.crm.dynamics.com",

        c = Curl::Easy.new(url) do |http|
          # Set up headers.
          http.headers["Connection"] = "Keep-Alive"
          http.headers["Content-type"] = "application/soap+xml; charset=UTF-8"
          http.headers["Content-length"] = request.length

          http.ssl_verify_peer = false
          http.timeout = 60
          http.follow_location = true
          http.ssl_version = 3
          # http.verbose = 1
        end

        if c.http_post(request)
          response = c.body_str
        else

        end

        puts "RESPONSE"
        puts response

        response
      end

    end
  end
end
