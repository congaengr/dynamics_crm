# SOAP Only Walk through
# http://code.msdn.microsoft.com/CRM-Online-2011-WebServices-14913a16
#
# PHP starting point: 
# http://crmtroubleshoot.blogspot.com.au/2013/07/dynamics-crm-2011-php-and-soap-using.html
# 
# OCP: Open Commerce Platform
# https://community.dynamics.com/crm/b/crmgirishraja/archive/2012/09/04/authentication-with-dynamics-crm-online-on-ocp-office-365.aspx
module DynamicsCRM

  class Client
    extend Forwardable
    include XML::MessageBuilder

    # The Login URL and Region are located in the client's Organization WSDL.
    # https://tinderboxdev.api.crm.dynamics.com/XRMServices/2011/Organization.svc?wsdl=wsdl0
    # 
    # Login URL: Policy -> Issuer -> Address
    # Region: SecureTokenService -> AppliesTo
    LOGIN_URL = "https://login.microsoftonline.com/RST2.srf"
    REGION = 'urn:crmna:dynamics.com'

    attr_accessor :logger, :caller_id

    # Initializes Client instance.
    # Requires: organization_name
    # Optional: hostname
    def initialize(config={organization_name: nil, hostname: nil, caller_id: nil})
      raise RuntimeError.new("organization_name is required") if config[:organization_name].nil?

      @organization_name = config[:organization_name]
      @hostname = config[:hostname] || "#{@organization_name}.api.crm.dynamics.com"
      @organization_endpoint = "https://#{@hostname}/XRMServices/2011/Organization.svc"
      @caller_id = config[:caller_id]
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

      soap_response = post(LOGIN_URL, build_ocp_request(username, password))

      document = REXML::Document.new(soap_response)
      # Check for Fault
      fault_xml = document.get_elements("//[local-name() = 'Fault']")
      raise XML::Fault.new(fault_xml) if fault_xml.any?

      cipher_values = document.get_elements("//CipherValue")

      if cipher_values && cipher_values.length > 0
        @security_token0 = cipher_values[0].text
        @security_token1 = cipher_values[1].text
        # Use local-name() to ignore namespace.
        @key_identifier = document.get_elements("//[local-name() = 'KeyIdentifier']").first.text
      else
        raise RuntimeError.new(soap_response)
      end

      true
    end

    # These are all the operations defined by the Dynamics WSDL.
    # Tag names are case-sensitive.
    def create(entity_name, attributes)

      entity = XML::Entity.new(entity_name)
      entity.attributes = XML::Attributes.new(attributes)

      xml_response = post(@organization_endpoint, create_request(entity))
      return Response::CreateResult.new(xml_response)
    end

    # http://crmtroubleshoot.blogspot.com.au/2013/07/dynamics-crm-2011-php-and-soap-calls.html
    def retrieve(entity_name, guid, columns=[])

      column_set = XML::ColumnSet.new(columns)
      request = retrieve_request(entity_name, guid, column_set)

      xml_response = post(@organization_endpoint, request)
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

      query = XML::Query.new(entity_name)
      query.columns = columns
      query.criteria = XML::Criteria.new(criteria)

      request = build_envelope('RetrieveMultiple') do
        %Q{
        <RetrieveMultiple xmlns="http://schemas.microsoft.com/xrm/2011/Contracts/Services">
          #{query.to_xml}
        </RetrieveMultiple>
        }
      end

      xml_response = post(@organization_endpoint, request)
      return Response::RetrieveMultipleResult.new(xml_response)
    end

    # Update entity attributes
    def update(entity_name, guid, attributes)

      entity = XML::Entity.new(entity_name)
      entity.id = guid
      entity.attributes = XML::Attributes.new(attributes)

      request = update_request(entity)
      xml_response = post(@organization_endpoint, request)
      return Response::UpdateResponse.new(xml_response)
    end 

    def delete(entity_name, guid)
      request = delete_request(entity_name, guid)

      xml_response = post(@organization_endpoint, request)
      return Response::DeleteResponse.new(xml_response)
    end

    def execute(action, parameters={}, response_class=nil)
      request = execute_request(action, parameters)
      xml_response = post(@organization_endpoint, request)

      response_class ||= Response::ExecuteResult
      return response_class.new(xml_response)
    end

    def associate(entity_name, guid, relationship, related_entities)
      request = associate_request(entity_name, guid, relationship, related_entities)
      xml_response = post(@organization_endpoint, request)
      return Response::AssociateResponse.new(xml_response)
    end

    def disassociate(entity_name, guid, relationship, related_entities)
      request = disassociate_request(entity_name, guid, relationship, related_entities)
      xml_response = post(@organization_endpoint, request)
      return Response::DisassociateResponse.new(xml_response)
    end

    def upload_file(entity_name, entity_id, file, subject=nil, text="")
      if file.is_a?(String) && File.exists?(file)
        file = File.new(file)
      end

      raise "File must be a valid File instance" unless file.is_a?(File)

      file_name = File.basename(file.path)
      extention_name = File.extname(file_name)
      mime_type = MimeMagic.by_path(file.path)

      attributes = {
        objectid: {id: entity_id, logical_name: entity_name},
        subject: subject || file_name,
        notetext: text || "",
        filename: file_name,
        isdocument: true,
        documentbody: ::Base64.encode64(file.read),
        filesize: File.size(file.path),
        mimetype: mime_type
      }

      self.create("annotation", attributes)
    end

    def attachments(entity_id, columns=["filename", "documentbody", "mimetype"])
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

    def who_am_i
      self.execute('WhoAmI')
    end

    protected

    def post(url, request)

      log_xml("REQUEST", request)

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

      log_xml("RESPONSE", response)

      response
    end

    def log_xml(title, xml)
      return unless logger

      logger.puts(title)
      doc = REXML::Document.new(xml)
      formatter.write(doc.root, logger)
      logger.puts
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