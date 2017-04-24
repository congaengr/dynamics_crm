require 'spec_helper'
require 'tempfile'

describe DynamicsCRM::Client do
  let(:subject) { DynamicsCRM::Client.new(organization_name: "tinderboxdev")}

  describe "#authenticate" do
    it "raises arugment error when no parameters are passed" do
      expect { subject.authenticate() }.to raise_error(ArgumentError)
    end

    context "Online" do
      it "authenticates with username and password" do

        allow(subject).to receive(:post).and_return(fixture("request_security_token_response"))

        subject.authenticate('testing', 'password')

        expect(subject.instance_variable_get("@security_token0")).to start_with("tMFpDJbJHcZnRVuby5cYmRbCJo2OgOFLEOrUHj+wz")
        expect(subject.instance_variable_get("@security_token1")).to start_with("CX7BFgRnW75tE6GiuRICjeVDV+6q4KDMKLyKmKe9A8U")
        expect(subject.instance_variable_get("@key_identifier")).to eq("D3xjUG3HGaQuKyuGdTWuf6547Lo=")
      end

      # This is only method in this suite that actually sends a POST message to Dynamics.
      # This covers the post() and fault parsing logic.
      it "fails to authenticate with invalid credentials" do
        begin
          subject.authenticate('testuser@orgnam.onmicrosoft.com', 'qwerty')
          fail("Expected Fault to be raised")
        rescue DynamicsCRM::XML::Fault => f
          expect(f.code).to eq("S:Sender")
          expect(f.subcode).to eq("wst:FailedAuthentication")
          expect(f.reason).to eq("Authentication Failure")
        end
      end
    end

    context "On-Premise" do
      let(:subject) { DynamicsCRM::Client.new(hostname: "customers.crm.psav.com")}

      it "authenticates with username and password" do

        allow(subject).to receive(:post).and_return(fixture("request_security_token_response_onpremise"))

        subject.authenticate('testing', 'password')

        expect(subject.instance_variable_get("@security_token0")).to start_with("ydfdQsDU9ow4XhoBi+0+n+/9Z7Dvfi")
        expect(subject.instance_variable_get("@security_token1")).to start_with("GcCk8ivhLAAPEbQI8qScynWLReTWE0AC5")
        expect(subject.instance_variable_get("@key_identifier")).to eq("_ed121435-64ea-45b0-9b15-e5769afdb746")

        expect(subject.instance_variable_get("@cert_issuer_name").strip).to start_with("SERIALNUMBER=12369287, CN=Go Daddy Secure")
        expect(subject.instance_variable_get("@cert_serial_number")).to eq("112094107365XXXXX")
        expect(subject.instance_variable_get("@server_secret")).to eq("XZwQpJKfAy00NNWU1RwdtDpVyW/nfabuCq4H38GgKrM=")
      end
    end

  end

  describe "#retrieve" do
    before(:each) do
      allow(subject).to receive(:post).and_return(fixture("retrieve_account_all_columns"))
    end

    let(:result) { subject.retrieve("account", "93f0325c-a592-e311-b7f3-6c3be5a8a0c8") }

    it "retrieves object by id and acts as hash" do
      expect(result).to be_a(DynamicsCRM::Response::RetrieveResult)
      expect(result.type).to eq("account")
      expect(result.id).to eq("93f0325c-a592-e311-b7f3-6c3be5a8a0c8")
      expect(result.name).to eq("Adventure Works (sample)")
    end

    it "exposes entity object" do
      entity = result.entity

      expect(entity).to be_a(DynamicsCRM::XML::Entity)
      expect(entity.attributes).to be_a(DynamicsCRM::XML::Attributes)
      expect(entity.attributes.merged).to eq(false)
      expect(entity.attributes.nothing).to be_nil

      expect(entity.formatted_values).to be_a(DynamicsCRM::XML::FormattedValues)
      expect(entity.formatted_values.merged).to eq('No')
      expect(entity.formatted_values.nothing).to be_nil
    end
  end

  describe "#retrieve_multiple" do
    it "retrieves multiple entities by criteria" do

      allow(subject).to receive(:post).and_return(fixture("retrieve_multiple_result"))

      result = subject.retrieve_multiple("account", ["name", "Equal", "Test Account"], columns=[])

      expect(result).to be_a(DynamicsCRM::Response::RetrieveMultipleResult)

      expect(result['EntityName']).to eq('account')
      expect(result['MinActiveRowVersion']).to eq(-1)
      expect(result['MoreRecords']).to eq(false)
      expect(result['PagingCookie']).not_to be_empty
      expect(result['TotalRecordCount']).to eq(-1)
      expect(result['TotalRecordCountLimitExceeded']).to eq(false)

      expect(result.entities.size).to eq(3)
      entities = result.entities

      entities[0].logical_name == "account"
      expect(entities[0].id).to eq("7bf2e032-ad92-e311-9752-6c3be5a87df0")
      expect(entities[0].attributes["accountid"]).to eq("7bf2e032-ad92-e311-9752-6c3be5a87df0")

      expect(entities[1].attributes["accountid"]).to eq("dbe9d7c9-2c98-e311-9752-6c3be5a87df0")
      expect(entities[2].attributes["accountid"]).to eq("8ff0325c-a592-e311-b7f3-6c3be5a8a0c8")
    end

    it "retrieves multiple entities by criteria using OR" do

      allow(subject).to receive(:post).and_return(fixture("retrieve_multiple_result"))

      result = subject.retrieve_multiple("account", ["name", "Equal", "Test Account"], columns=[], 'Or')

      expect(result).to be_a(DynamicsCRM::Response::RetrieveMultipleResult)
    end

    it "retrieves multiple entities by QueryExpression" do
      allow(subject).to receive(:post).and_return(fixture("retrieve_multiple_result"))

      query = DynamicsCRM::XML::QueryExpression.new('account')
      query.columns = %w(accountid name)
      query.criteria.add_condition('name', 'Equal', 'Test Account')

      result = subject.retrieve_multiple(query)

      expect(result).to be_a(DynamicsCRM::Response::RetrieveMultipleResult)

      expect(result['EntityName']).to eq('account')
      expect(result.entities.size).to eq(3)
    end
  end

  describe "#retrieve_attachments" do
    it "retrieves document records from annotation object" do
      allow(subject).to receive(:post).and_return(fixture("retrieve_multiple_result"))

      result = subject.retrieve_attachments("93f0325c-a592-e311-b7f3-6c3be5a8a0c8")
      expect(result).to be_a(DynamicsCRM::Response::RetrieveMultipleResult)
    end
  end

  describe "#fetch" do
    it "uses FetchXML to retrieve multiple" do

      allow(subject).to receive(:post).and_return(fixture("fetch_xml_response"))

      xml = %Q{
        <fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="true">
          <entity name="new_tinderboxdocument">
            <attribute name="new_tinderboxdocumentid" />
            <attribute name="new_name" />
            <attribute name="createdon" />
            <order attribute="new_name" descending="false" />
            <link-entity name="systemuser" from="systemuserid" to="createdby" alias="aa">
              <link-entity name="account" from="createdby" to="systemuserid" alias="ab">
                <link-entity name="transactioncurrency" from="transactioncurrencyid" to="transactioncurrencyid" alias="ac"></link-entity>
              </link-entity>
            </link-entity>
          </entity>
        </fetch>
      }

      entity_collection = subject.fetch(xml)
      expect(entity_collection).to be_a(DynamicsCRM::XML::EntityCollection)

      expect(entity_collection.entity_name).to eq('new_tinderboxdocument')
      expect(entity_collection.min_active_row_version).to eq(-1)
      expect(entity_collection.more_records).to eq(false)
      expect(entity_collection.paging_cookie).not_to be_empty
      expect(entity_collection.total_record_count).to eq(-1)
      expect(entity_collection.total_record_count_limit_exceeded).to eq(false)

      expect(entity_collection.entities.size).to eq(3)

      entity = entity_collection.entities.first
      expect(entity.id).to eq("9c27cf91-ada3-e311-b64f-6c3be5a87df0")
      expect(entity.logical_name).to eq("new_tinderboxdocument")
      expect(entity.attributes["new_tinderboxdocumentid"]).to eq(entity.id)
      expect(entity.attributes["new_name"]).to eq("6 orders of Product SKU JJ202")
    end
  end


  describe "#create" do
    it "creates new entity with parameters" do

      allow(subject).to receive(:post).and_return(fixture("create_response"))

      result = subject.create("account", {name: "Adventure Works"})

      expect(result).to be_a(DynamicsCRM::Response::CreateResult)
      expect(result.id).to eq("c4944f99-b5a0-e311-b64f-6c3be5a87df0")
      expect(result.Id).to eq("c4944f99-b5a0-e311-b64f-6c3be5a87df0")
    end

    it "creates new entity with custom fields and relationship" do

      params = {
               :tndrbox_id => 929177,
             :tndrbox_name => "TEST",
      :tndrbox_description => "",
           :tndrbox_status => "Draft",
            :tndrbox_views => 0,
         :tndrbox_category => nil,
          "tndrbox_opportunity_id" => {
                        :id => "71a4a3af-d7ab-e411-80c7-00155dd44307",
              :logical_name => "opportunity"
          },
          :tndrbox_value => {
              :value => 0.0,
               :type => "Money"
          }
      }

      allow(subject).to receive(:post).and_return(fixture("create_response"))

      result = subject.create('opportunity', params)

      expect(result).to be_a(DynamicsCRM::Response::CreateResult)
      expect(result.id).to eq("c4944f99-b5a0-e311-b64f-6c3be5a87df0")
      expect(result.Id).to eq("c4944f99-b5a0-e311-b64f-6c3be5a87df0")
    end
  end

  describe "#create_attachment" do
    it "creates new record in annotation entity" do

      file = Tempfile.new(["sample-file", "pdf"])

      expect(subject).to receive(:create).with("annotation", {
        objectid: {id: "f4944f99-b5a0-e311-b64f-6c3be5a87df0", logical_name: "opportunity"},
        subject: "Sample Subject",
        notetext: "Post message",
        filename: "testfile.pdf",
        isdocument: true,
        documentbody: ::Base64.encode64(""),
        filesize: 0,
        mimetype: nil
      })

      options = {
        filename: "testfile.pdf",
        document: file,
        subject: "Sample Subject",
        text: "Post message"
      }

      result = subject.create_attachment("opportunity", "f4944f99-b5a0-e311-b64f-6c3be5a87df0", options)
    end
  end

  describe "#update" do
    it "updates entity by id" do

      allow(subject).to receive(:post).and_return(fixture("update_response"))

      result = subject.update("account", "c4944f99-b5a0-e311-b64f-6c3be5a87df0", {name: "Adventure Park"})

      expect(result).to be_a(DynamicsCRM::Response::UpdateResponse)
    end
  end

  describe "#delete" do
    it "deletes entity by id" do

      allow(subject).to receive(:post).and_return(fixture("update_response"))

      result = subject.delete("account", "c4944f99-b5a0-e311-b64f-6c3be5a87df0")

      expect(result).to be_a(DynamicsCRM::Response::DeleteResponse)
    end
  end

  # Metadata Requests

  describe "#retrieve_all_entities" do
    it "retrieve entity list" do

      allow(subject).to receive(:post).and_return(fixture("retrieve_all_entities"))

      result = subject.retrieve_all_entities

      expect(result).to be_a(DynamicsCRM::Metadata::RetrieveAllEntitiesResponse)
      expect(result.entities).not_to be_nil

      entities = result.entities
      expect(entities.size).to eq(3)

      expect(entities[0].LogicalName).to eq("opportunity")
      expect(entities[1].LogicalName).to eq("new_tinderboxdocument")
      expect(entities[2].LogicalName).to eq("new_tinderboxcontent")
    end
  end

  describe "#retrieve_entity" do
    it "retrieve entity metadata" do

      allow(subject).to receive(:post).and_return(fixture("retrieve_entity_response"))

      result = subject.retrieve_entity("opportunity")

      expect(result).to be_a(DynamicsCRM::Metadata::RetrieveEntityResponse)
      expect(result.entity).not_to be_nil
      entity = result.entity
      expect(entity).to be_a(DynamicsCRM::Metadata::EntityMetadata)

      expect(entity.LogicalName).to eq("opportunity")
      expect(entity.PrimaryIdAttribute).to eq("opportunityid")
      expect(entity.PrimaryNameAttribute).to eq("name")
    end
  end

  describe "#retrieve_attribute" do
    it "retrieve attribute metadata" do

      allow(subject).to receive(:post).and_return(fixture("retrieve_attribute_response"))

      result = subject.retrieve_attribute("new_tinderboxdocument", "new_value")

      expect(result).to be_a(DynamicsCRM::Metadata::RetrieveAttributeResponse)
      expect(result.attribute).not_to be_nil
      attribute = result.attribute

      expect(attribute.EntityLogicalName).to eq("new_tinderboxdocument")
      expect(attribute.LogicalName).to eq("new_value")
    end
  end

  context "many-to-many relationships" do
    let(:contacts) {
      [ DynamicsCRM::XML::EntityReference.new("contact", "53291AAB-4A9A-E311-B097-6C3BE5A8DD60"),
        DynamicsCRM::XML::EntityReference.new("contact", "3DEDA796-4A9A-E311-B097-6C3BE5A8DD60")]
    }

    describe "#associate" do
      it "associates contacts with account" do
        allow(subject).to receive(:post).and_return(fixture("associate_response"))

        subject.associate("account", "7BF2E032-AD92-E311-9752-6C3BE5A87DF0", "contact_customer_accounts", contacts)
      end
    end

    describe "#disassociate" do
      it "disassociates contacts with accounts" do
        allow(subject).to receive(:post).and_return(fixture("disassociate_response"))

        subject.disassociate("account", "7BF2E032-AD92-E311-9752-6C3BE5A87DF0", "contact_customer_accounts", contacts)
      end
    end
  end

  describe "#retrieve_metadata_changes" do
    it "retrieves entity metadata" do
      allow(subject).to receive(:post).and_return(fixture("retrieve_metadata_changes_response"))

      entity_filter = DynamicsCRM::Metadata::FilterExpression.new('Or')
      entity_filter.add_condition(['SchemaName', 'Equals', 'Contact'])
      entity_filter.add_condition(['SchemaName', 'Equals', 'Annotation'])
      entity_filter.add_condition(['SchemaName', 'Equals', 'Incident'])
      entity_properties = DynamicsCRM::Metadata::PropertiesExpression.new(['Attributes'])

      attribute_filter = DynamicsCRM::Metadata::FilterExpression.new('And')
      attribute_filter.add_condition(['IsCustomAttribute', 'Equals', false])
      attribute_properties = DynamicsCRM::Metadata::PropertiesExpression.new(['LogicalName', 'AttributeType', 'AttributeOf', 'DisplayName', 'RequiredLevel'])
      attribute_query = DynamicsCRM::Metadata::AttributeQueryExpression.new(attribute_filter, attribute_properties)

      entity_query = DynamicsCRM::Metadata::EntityQueryExpression.new({
        criteria: entity_filter,
        properties: entity_properties,
        attribute_query: attribute_query
      })

      result = subject.retrieve_metadata_changes(entity_query)
      expect(result).to be_a(DynamicsCRM::Metadata::RetrieveMetadataChangesResponse)
      entities = result.entities
      expect(entities).not_to be_nil
      expect(entities.size).to eq(3)

      attributes = entities[0].attributes
      expect(attributes.size).to eq(2)
      attribute  = attributes.first
      expect(attribute.logical_name).to eq("contactid")
      expect(attribute.attribute_of).to be_empty
      expect(attribute.type).to eq("Lookup")
      expect(attribute.display_name).to eq("Contact")
      expect(attribute.required_level).to eq("None")

      attributes = entities[1].attributes
      expect(attributes.size).to eq(2)
      attribute  = attributes.first
      expect(attribute.logical_name).to eq("customertypecodename")
      expect(attribute.attribute_of).to eq("customertypecode")
      expect(attribute.type).to eq("Virtual")
      expect(attribute.display_name).to be_empty
      expect(attribute.required_level).to eq("None")

      attributes = entities[2].attributes
      expect(attributes.size).to eq(2)
      attribute = attributes.first
      expect(attribute.logical_name).to eq("createdonbehalfbyyominame")
      expect(attribute.attribute_of).to eq("createdonbehalfby")
      expect(attribute.type).to eq("String")
      expect(attribute.display_name).to be_empty
      expect(attribute.required_level).to eq("None")
    end
  end

  describe "#who_am_i" do
    it "returns user information" do
      allow(subject).to receive(:post).and_return(fixture("who_am_i_result"))

      response = subject.who_am_i
      expect(response.UserId).to eq("1bfa3886-df7e-468c-8435-b5adfb0441ed")
      expect(response.BusinessUnitId).to eq("4e87d619-838a-e311-89a7-6c3be5a80184")
      expect(response.OrganizationId).to eq("0140d597-e270-494a-89e1-bd0b43774e50")
    end
  end

  describe "#load_entity" do
    it "returns Model::Opportunity" do
      response = subject.load_entity("opportunity", "c4944f99-b5a0-e311-b64f-6c3be5a87df0")
      expect(response).to be_a(DynamicsCRM::Model::Opportunity)
    end

    it "returns Model::Entity" do
      response = subject.load_entity("account", "c4944f99-b5a0-e311-b64f-6c3be5a87df0")
      expect(response).to be_a(DynamicsCRM::Model::Entity)
    end
  end

  describe '#determine_region' do
    context 'Client receives only hostname' do
      it 'North America region' do
        client = DynamicsCRM::Client.new(hostname: 'xunda.crm.dynamics.com')
        expect(client.region).to eq('urn:crmna:dynamics.com')
      end
      it 'South America region' do
        client = DynamicsCRM::Client.new(hostname: 'xunda.api.crm2.dynamics.com')
        expect(client.region).to eq('urn:crmsam:dynamics.com')
      end
      it 'Canada region' do
        client = DynamicsCRM::Client.new(organization_name: 'xunda.crm3.dynamics.com')
        expect(client.region).to eq('urn:crmcan:dynamics.com')
      end
      it 'India region' do
        client = DynamicsCRM::Client.new(organization_name: 'xunda.crm8.dynamics.com')
        expect(client.region).to eq('urn:crmind:dynamics.com')
      end
    end
    context 'Client receives only organization_name' do
      it 'return the correct region' do
        client = DynamicsCRM::Client.new(organization_name: 'xunda')
        expect(client.region).to eq('urn:crmna:dynamics.com')
      end
    end
  end
end
