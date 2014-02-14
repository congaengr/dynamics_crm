require "mscrm/soap/version"
require "mscrm/soap/message_builder"
require "mscrm/soap/model/attributes"
require "mscrm/soap/model/entity"
require "mscrm/soap/model/result"
require "mscrm/soap/model/retrieve_result"
require "mscrm/soap/model/create_result"

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

        entity = Model::Entity.new('account')
        entity.attributes = Model::Attributes.new(attributes)

        xml_response = post(@organization_endpoint, create_request(entity))
        return Model::CreateResult.new(xml_response)
      end

      # http://crmtroubleshoot.blogspot.com.au/2013/07/dynamics-crm-2011-php-and-soap-calls.html
      def retrieve(entity_name, guid, columns=[])

        # name, telephone1, websiteurl, address1_composite, primarycontactid
        column_set = "<b:AllColumns>true</b:AllColumns>"
        if columns.any?
          column_set = '<b:Columns xmlns:c="http://schemas.microsoft.com/2003/10/Serialization/Arrays">'
          columns.each do |name|
            column_set << "<c:string>#{name}</c:string>"
          end
          column_set << '</b:Columns>'
        end

        # Tag name case MATTERS!
        request = build_envelope('Retrieve') do
          %Q{
            <Retrieve xmlns="http://schemas.microsoft.com/xrm/2011/Contracts/Services">
              <entityName>#{entity_name}</entityName>
              <id>#{guid}</id>
              <columnSet xmlns:b="http://schemas.microsoft.com/xrm/2011/Contracts" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
                #{column_set}
              </columnSet>
            </Retrieve>
          }
        end

        xml_response = post(@organization_endpoint, request)
        return Model::RetrieveResult.new(xml_response)
      end

      def retrieve_multiple
      end

      def update
      end 

      def delete
      end

      def execute
      end

      def associate
      end

      def disassociate
      end

      def who_am_i

        xml = <<EOF
         <s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">
          #{build_header('Execute')}
          <s:Body>
           <Execute xmlns="http://schemas.microsoft.com/xrm/2011/Contracts/Services" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
            <request i:type="b:WhoAmIRequest" xmlns:a="http://schemas.microsoft.com/xrm/2011/Contracts" xmlns:b="http://schemas.microsoft.com/crm/2011/Contracts">
             <a:Parameters xmlns:c="http://schemas.datacontract.org/2004/07/System.Collections.Generic" />
             <a:RequestId i:nil="true" />
             <a:RequestName>WhoAmI</a:RequestName>
            </request>
           </Execute>
          </s:Body>
         </s:Envelope>
EOF

        return post(@organization_endpoint, xml)
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
