# SOAP Only Walk through
# http://code.msdn.microsoft.com/CRM-Online-2011-WebServices-14913a16
#
# PHP starting point:
# http://crmtroubleshoot.blogspot.com.au/2013/07/dynamics-crm-2011-php-and-soap-using.html
#
# OCP: Open Commerce Platform
# https://community.dynamics.com/crm/b/crmgirishraja/archive/2012/09/04/authentication-with-dynamics-crm-online-on-ocp-office-365.aspx

require 'forwardable'
require 'digest/sha1'
require 'openssl'
require 'open-uri'

module DynamicsCRM

  class Client
    extend Forwardable
    include XML::MessageBuilder

    attr_accessor :logger, :caller_id, :timeout
    attr_reader :hostname, :region, :organization_endpoint, :login_url

    OCP_LOGIN_URL = 'https://login.microsoftonline.com/RST2.srf'

    REGION = {
      "crm9.dynamics.com" => "urn:crmgcc:dynamics.com",
      "crm7.dynamics.com" => "urn:crmjpn:dynamics.com",
      "crm6.dynamics.com" => "urn:crmoce:dynamics.com",
      "crm5.dynamics.com" => "urn:crmapac:dynamics.com",
      "crm4.dynamics.com" => "urn:crmemea:dynamics.com",
      "crm2.dynamics.com" => "urn:crmsam:dynamics.com",
      "crm.dynamics.com"  => "urn:crmna:dynamics.com",
    }

    # Initializes Client instance.
    # Requires: organization_name
    # Optional: hostname
    def initialize(config={organization_name: nil, hostname: nil, caller_id: nil, login_url: nil, region: nil})
      raise RuntimeError.new("organization_name or hostname is required") if config[:organization_name].nil? && config[:hostname].nil?

      @organization_name = config[:organization_name]
      @hostname = config[:hostname] || "#{@organization_name}.api.crm.dynamics.com"
      @organization_endpoint = "https://#{@hostname}/XRMServices/2011/Organization.svc"
      REGION.default = @organization_endpoint
      @caller_id = config[:caller_id]
      @timeout = config[:timeout] || 120

      # The Login URL and Region are located in the client's Organization WSDL.
      # https://tinderboxdev.api.crm.dynamics.com/XRMServices/2011/Organization.svc?wsdl=wsdl0
      #
      # Login URL: Policy -> Issuer -> Address
      # Region: SecureTokenService -> AppliesTo
      @login_url = config[:login_url]
      @region = config[:region] || determine_region
    end

    # Public: Authenticate User
    #
    # Examples
    #
    #   client.authenticate('test@orgnam.onmicrosoft.com', 'password')
    #   # => true || raised Fault
    #
    # Returns true on success or raises Fault
    def authenticate(username, password)

      @username = username
      @password = password

      auth_request = if on_premise?
        build_on_premise_request(username, password, region, login_url)
      else
        build_ocp_request(username, password, region, login_url)
      end

      soap_response = post(login_url, auth_request)

      document = REXML::Document.new(soap_response)
      # Check for Fault
      fault_xml = document.get_elements("//[local-name() = 'Fault']")
      raise XML::Fault.new(fault_xml) if fault_xml.any?

      if on_premise?
        @security_token0 = document.get_elements("//e:CipherValue").first.text.to_s
        @security_token1 = document.get_elements("//xenc:CipherValue").last.text.to_s
        @key_identifier = document.get_elements("//o:KeyIdentifier").first.text
        @cert_issuer_name = document.get_elements("//X509IssuerName").first.text
        @cert_serial_number = document.get_elements("//X509SerialNumber").first.text
        @server_secret = document.get_elements("//trust:BinarySecret").first.text

        @header_current_time = get_current_time
        @header_expires_time = get_current_time_plus_hour
        @timestamp = '<u:Timestamp xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" u:Id="_0"><u:Created>' + @header_current_time + '</u:Created><u:Expires>' + @header_expires_time + '</u:Expires></u:Timestamp>'
        @digest_value = Digest::SHA1.base64digest @timestamp
        @signature = '<SignedInfo xmlns="http://www.w3.org/2000/09/xmldsig#"><CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"></CanonicalizationMethod><SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#hmac-sha1"></SignatureMethod><Reference URI="#_0"><Transforms><Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"></Transform></Transforms><DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"></DigestMethod><DigestValue>' + @digest_value + '</DigestValue></Reference></SignedInfo>'
        @signature_value = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), Base64.decode64(@server_secret), @signature)).chomp
      else
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


      true
    end

    # These are all the operations defined by the Dynamics WSDL.
    # Tag names are case-sensitive.
    def create(entity_name, attributes)

      entity = XML::Entity.new(entity_name)
      entity.attributes = XML::Attributes.new(attributes)

      xml_response = post(organization_endpoint, create_request(entity))
      return Response::CreateResult.new(xml_response)
    end

    # http://crmtroubleshoot.blogspot.com.au/2013/07/dynamics-crm-2011-php-and-soap-calls.html
    def retrieve(entity_name, guid, columns=[])

      column_set = XML::ColumnSet.new(columns)
      request = retrieve_request(entity_name, guid, column_set)

      xml_response = post(organization_endpoint, request)
      return Response::RetrieveResult.new(xml_response)
    end

    def rollup(target_entity, query, rollup_type="Related")
        self.execute("Rollup", {
          Target: target_entity,
          Query: query,
          RollupType: rollup_type
        })
    end

    def retrieve_multiple(entity_name, criteria=[], columns=[])

      query = XML::QueryExpression.new(entity_name)
      query.columns = columns
      query.criteria = XML::Criteria.new(criteria)

      request = retrieve_multiple_request(query)
      xml_response = post(organization_endpoint, request)
      return Response::RetrieveMultipleResult.new(xml_response)
    end

    def fetch(fetchxml)
      response = self.execute("RetrieveMultiple", {
        Query: XML::FetchExpression.new(fetchxml)
      })
      response['EntityCollection']
    end

    # Update entity attributes
    def update(entity_name, guid, attributes)

      entity = XML::Entity.new(entity_name)
      entity.id = guid
      entity.attributes = XML::Attributes.new(attributes)

      request = update_request(entity)
      xml_response = post(organization_endpoint, request)
      return Response::UpdateResponse.new(xml_response)
    end

    def delete(entity_name, guid)
      request = delete_request(entity_name, guid)

      xml_response = post(organization_endpoint, request)
      return Response::DeleteResponse.new(xml_response)
    end

    def execute(action, parameters={}, response_class=nil)
      request = execute_request(action, parameters)
      xml_response = post(organization_endpoint, request)

      response_class ||= Response::ExecuteResult
      return response_class.new(xml_response)
    end

    def execute_simple_action_tag(action, parameters={}, response_class=nil)
      request = execute_request(action, parameters, false)
      xml_response = post(organization_endpoint, request)

      response_class ||= Response::ExecuteResult
      return response_class.new(xml_response)
    end

    def associate(entity_name, guid, relationship, related_entities)
      request = associate_request(entity_name, guid, relationship, related_entities)
      xml_response = post(organization_endpoint, request)
      return Response::AssociateResponse.new(xml_response)
    end

    def disassociate(entity_name, guid, relationship, related_entities)
      request = disassociate_request(entity_name, guid, relationship, related_entities)
      xml_response = post(organization_endpoint, request)
      return Response::DisassociateResponse.new(xml_response)
    end

    def create_attachment(entity_name, entity_id, options={})
      raise "options must contain a document entry" unless options[:document]

      file_name = options[:filename]
      document = options[:document]
      subject = options[:subject]
      text = options[:text] || ""

      if document.is_a?(String) && File.exists?(document)
        file = File.new(document)
      elsif document.is_a?(String) && document.start_with?("http")
        require 'open-uri'
        file = open(document)
      else
        file = document
      end

      if file.respond_to?(:base_uri)
        file_name ||= File.basename(file.base_uri.path)
        mime_type = MimeMagic.by_path(file.base_uri.path)
      elsif file.respond_to?(:path)
        file_name ||= File.basename(file.path)
        mime_type = MimeMagic.by_path(file.path)
      else
        raise "file must be a valid File object, file path or URL"
      end

      documentbody = file.read
      attributes = {
        objectid: {id: entity_id, logical_name: entity_name},
        subject: subject || file_name,
        notetext: text || "",
        filename: file_name,
        isdocument: true,
        documentbody: ::Base64.encode64(documentbody),
        filesize: documentbody.length,
        mimetype: mime_type
      }

      self.create("annotation", attributes)
    end

    def retrieve_attachments(entity_id, columns=["filename", "documentbody", "mimetype"])
      self.retrieve_multiple("annotation", [["objectid", "Equal", entity_id], ["isdocument", "Equal", true]], columns)
    end

    # Metadata Calls
    # EntityFilters Enum: Default, Entity, Attributes, Privileges, Relationships, All
    def retrieve_all_entities
      response = self.execute("RetrieveAllEntities", {
        EntityFilters: "Entity",
        RetrieveAsIfPublished: true
        },
        Metadata::RetrieveAllEntitiesResponse)
    end

    # EntityFilters Enum: Default, Entity, Attributes, Privileges, Relationships, All
    def retrieve_entity(logical_name, entity_filter="Attributes")
      self.execute("RetrieveEntity", {
        LogicalName: logical_name,
        MetadataId: "00000000-0000-0000-0000-000000000000",
        EntityFilters: entity_filter,
        RetrieveAsIfPublished: true
        },
        Metadata::RetrieveEntityResponse)
    end

    def retrieve_attribute(entity_logical_name, logical_name)
      self.execute("RetrieveAttribute", {
        EntityLogicalName: entity_logical_name,
        LogicalName: logical_name,
        MetadataId: "00000000-0000-0000-0000-000000000000",
        RetrieveAsIfPublished: true
        },
        Metadata::RetrieveAttributeResponse)
    end

    def retrieve_metadata_changes(entity_query)
      self.execute("RetrieveMetadataChanges", {
        Query: entity_query
      },
      Metadata::RetrieveMetadataChangesResponse)
    end

    def who_am_i
      self.execute('WhoAmI')
    end

    def load_entity(logical_name, id)
      case logical_name
      when "opportunity"
        Model::Opportunity.new(id, self)
      else
        Model::Entity.new(logical_name, id, self)
      end
    end

    protected

    def on_premise?
      @on_premise ||= !(hostname =~ /\.dynamics\.com/i)
    end

    def organization_wsdl
      wsdl = open(organization_endpoint + "?wsdl=wsdl0").read
      @organization_wsdl ||= REXML::Document.new(wsdl)
    end

    def login_url
      @login_url ||= if on_premise?
        (organization_wsdl.document.get_elements("//ms-xrm:Identifier").first.text + "/13/usernamemixed").gsub("http://", "https://")
      else
        OCP_LOGIN_URL
      end
    end

    def determine_region
      hostname.match(/(crm\d?\.dynamics.com)/)
      REGION[$1]
    end

    def post(url, request)
      log_xml("REQUEST", request)

      c = Curl::Easy.new(url) do |http|
        # Set up headers.
        http.headers["Connection"] = "Keep-Alive"
        http.headers["Content-type"] = "application/soap+xml; charset=UTF-8"
        http.headers["Content-length"] = request.bytesize

        http.ssl_verify_peer = false
        http.timeout = timeout
        http.follow_location = true
        http.ssl_version = 1
        # http.verbose = 1
      end

      if c.http_post(request)
        response = c.body_str
      else
        # Do something here on error.
      end
      c.close

      log_xml("RESPONSE", response)

      response
    end

    def log_xml(title, xml)
      return unless logger

      logger.debug(title)
      doc = REXML::Document.new(xml)
      formatter.write(doc.root, logger)
      logger.debug("\n")
    end

    def formatter
      unless @formatter
        @formatter = REXML::Formatters::Pretty.new(2)
        @formatter.compact = true # This is the magic line that does what you need!
      end
      @formatter
    end

  end

end
