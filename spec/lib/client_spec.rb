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

        subject.stub(:post).and_return(fixture("request_security_token_response"))

        subject.authenticate('testing', 'password')

        subject.instance_variable_get("@security_token0").should start_with("tMFpDJbJHcZnRVuby5cYmRbCJo2OgOFLEOrUHj+wz")
        subject.instance_variable_get("@security_token1").should start_with("CX7BFgRnW75tE6GiuRICjeVDV+6q4KDMKLyKmKe9A8U")
        subject.instance_variable_get("@key_identifier").should == "D3xjUG3HGaQuKyuGdTWuf6547Lo="
      end

      # This is only method in this suite that actually sends a POST message to Dynamics.
      # This covers the post() and fault parsing logic.
      it "fails to authenticate with invalid credentials" do
        begin
          subject.authenticate('testuser@orgnam.onmicrosoft.com', 'qwerty')
          fail("Expected Fault to be raised")
        rescue DynamicsCRM::XML::Fault => f
          f.code.should == "S:Sender"
          f.subcode.should == "wst:FailedAuthentication"
          f.reason.should == "Authentication Failure"
        end
      end
    end

    context "On-Premise" do
      let(:subject) { DynamicsCRM::Client.new(organization_name: "psavtest", hostname: "psavtest.crm.powerobjects.net")}

      it "authenticates with username and password" do

        subject.stub(:post).and_return(fixture("request_security_token_response_onpremise"))

        subject.authenticate('testing', 'password')

        subject.instance_variable_get("@security_token0").should start_with("ydfdQsDU9ow4XhoBi+0+n+/9Z7Dvfi")
        subject.instance_variable_get("@security_token1").should start_with("GcCk8ivhLAAPEbQI8qScynWLReTWE0AC5")
        subject.instance_variable_get("@key_identifier").should == "_ed121435-64ea-45b0-9b15-e5769afdb746"

        subject.instance_variable_get("@cert_issuer_name").strip.should start_with("SERIALNUMBER=12369287, CN=Go Daddy Secure")
        subject.instance_variable_get("@cert_serial_number").should == "112094107365XXXXX"
        subject.instance_variable_get("@server_secret").should == "XZwQpJKfAy00NNWU1RwdtDpVyW/nfabuCq4H38GgKrM="
      end
    end

  end

  describe "#retrieve" do
    before(:each) do
      subject.stub(:post).and_return(fixture("retrieve_account_all_columns"))
    end

    let(:result) { subject.retrieve("account", "93f0325c-a592-e311-b7f3-6c3be5a8a0c8") }

    it "retrieves object by id and acts as hash" do
      result.should be_a(DynamicsCRM::Response::RetrieveResult)
      result.type.should == "account"
      result.id.should == "93f0325c-a592-e311-b7f3-6c3be5a8a0c8"
      result.name.should == "Adventure Works (sample)"
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

      subject.stub(:post).and_return(fixture("retrieve_multiple_result"))

      result = subject.retrieve_multiple("account", ["name", "Equal", "Test Account"], columns=[])

      result.should be_a(DynamicsCRM::Response::RetrieveMultipleResult)

      expect(result['EntityName']).to eq('account')
      expect(result['MinActiveRowVersion']).to eq(-1)
      expect(result['MoreRecords']).to eq(false)
      expect(result['PagingCookie']).not_to be_empty
      expect(result['TotalRecordCount']).to eq(-1)
      expect(result['TotalRecordCountLimitExceeded']).to eq(false)

      result.entities.size.should == 3
      entities = result.entities

      entities[0].logical_name == "account"
      entities[0].id.should == "7bf2e032-ad92-e311-9752-6c3be5a87df0"
      entities[0].attributes["accountid"].should == "7bf2e032-ad92-e311-9752-6c3be5a87df0"

      entities[1].attributes["accountid"].should == "dbe9d7c9-2c98-e311-9752-6c3be5a87df0"
      entities[2].attributes["accountid"].should == "8ff0325c-a592-e311-b7f3-6c3be5a8a0c8"
    end
  end

  describe "#retrieve_attachments" do
    it "retrieves document records from annotation object" do
      subject.stub(:post).and_return(fixture("retrieve_multiple_result"))

      result = subject.retrieve_attachments("93f0325c-a592-e311-b7f3-6c3be5a8a0c8")
      result.should be_a(DynamicsCRM::Response::RetrieveMultipleResult)
    end
  end

  describe "#fetch" do
    it "uses FetchXML to retrieve multiple" do

      subject.stub(:post).and_return(fixture("fetch_xml_response"))

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
      entity_collection.should be_a(DynamicsCRM::XML::EntityCollection)

      expect(entity_collection.entity_name).to eq('new_tinderboxdocument')
      expect(entity_collection.min_active_row_version).to eq(-1)
      expect(entity_collection.more_records).to eq(false)
      expect(entity_collection.paging_cookie).not_to be_empty
      expect(entity_collection.total_record_count).to eq(-1)
      expect(entity_collection.total_record_count_limit_exceeded).to eq(false)

      expect(entity_collection.entities.size).to eq(3)

      entity = entity_collection.entities.first
      entity.id.should == "9c27cf91-ada3-e311-b64f-6c3be5a87df0"
      entity.logical_name.should == "new_tinderboxdocument"
      entity.attributes["new_tinderboxdocumentid"].should == entity.id
      entity.attributes["new_name"].should == "6 orders of Product SKU JJ202"
    end
  end


  describe "#create" do
    it "creates new entity with parameters" do

      subject.stub(:post).and_return(fixture("create_response"))

      result = subject.create("account", {name: "Adventure Works"})

      result.should be_a(DynamicsCRM::Response::CreateResult)
      result.id.should == "c4944f99-b5a0-e311-b64f-6c3be5a87df0"
      result.Id.should == "c4944f99-b5a0-e311-b64f-6c3be5a87df0"
    end
  end

  describe "#create_attachment" do
    it "creates new record in annotation entity" do

      file = Tempfile.new(["sample-file", "pdf"])

      subject.should_receive(:create).with("annotation", {
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

      subject.stub(:post).and_return(fixture("update_response"))

      result = subject.update("account", "c4944f99-b5a0-e311-b64f-6c3be5a87df0", {name: "Adventure Park"})

      result.should be_a(DynamicsCRM::Response::UpdateResponse)
    end
  end

  describe "#delete" do
    it "deletes entity by id" do

      subject.stub(:post).and_return(fixture("update_response"))

      result = subject.delete("account", "c4944f99-b5a0-e311-b64f-6c3be5a87df0")

      result.should be_a(DynamicsCRM::Response::DeleteResponse)
    end
  end

  # Metadata Requests

  describe "#retrieve_all_entities" do
    it "retrieve entity list" do

      subject.stub(:post).and_return(fixture("retrieve_all_entities"))

      result = subject.retrieve_all_entities

      result.should be_a(DynamicsCRM::Metadata::RetrieveAllEntitiesResponse)
      result.entities.should_not be_nil

      entities = result.entities
      entities.size.should == 3

      entities[0].LogicalName.should == "opportunity"
      entities[1].LogicalName.should == "new_tinderboxdocument"
      entities[2].LogicalName.should == "new_tinderboxcontent"
    end
  end

  describe "#retrieve_entity" do
    it "retrieve entity metadata" do

      subject.stub(:post).and_return(fixture("retrieve_entity_response"))

      result = subject.retrieve_entity("opportunity")

      result.should be_a(DynamicsCRM::Metadata::RetrieveEntityResponse)
      result.entity.should_not be_nil
      entity = result.entity
      entity.should be_a(DynamicsCRM::Metadata::EntityMetadata)

      entity.LogicalName.should == "opportunity"
      entity.PrimaryIdAttribute.should == "opportunityid"
      entity.PrimaryNameAttribute.should == "name"
    end
  end

  describe "#retrieve_attribute" do
    it "retrieve attribute metadata" do

      subject.stub(:post).and_return(fixture("retrieve_attribute_response"))

      result = subject.retrieve_attribute("new_tinderboxdocument", "new_value")

      result.should be_a(DynamicsCRM::Metadata::RetrieveAttributeResponse)
      result.attribute.should_not be_nil
      attribute = result.attribute

      attribute.EntityLogicalName.should == "new_tinderboxdocument"
      attribute.LogicalName.should == "new_value"
    end
  end

  context "many-to-many relationships" do
    let(:contacts) {
      [ DynamicsCRM::XML::EntityReference.new("contact", "53291AAB-4A9A-E311-B097-6C3BE5A8DD60"),
        DynamicsCRM::XML::EntityReference.new("contact", "3DEDA796-4A9A-E311-B097-6C3BE5A8DD60")]
    }

    describe "#associate" do
      it "associates contacts with account" do
        subject.stub(:post).and_return(fixture("associate_response"))

        subject.associate("account", "7BF2E032-AD92-E311-9752-6C3BE5A87DF0", "contact_customer_accounts", contacts)
      end
    end

    describe "#disassociate" do
      it "disassociates contacts with accounts" do
        subject.stub(:post).and_return(fixture("disassociate_response"))

        subject.disassociate("account", "7BF2E032-AD92-E311-9752-6C3BE5A87DF0", "contact_customer_accounts", contacts)
      end
    end
  end

  describe "#retrieve_metadata_changes" do
    it "retrieves entity metadata" do
      subject.stub(:post).and_return(fixture("retrieve_metadata_changes_response"))

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
      result.should be_a(DynamicsCRM::Metadata::RetrieveMetadataChangesResponse)
      entities = result.entities
      entities.should_not be_nil
      entities.size.should eq(3)

      attributes = entities[0].attributes
      attributes.size.should eq(2)
      attribute  = attributes.first
      attribute.logical_name.should eq("contactid")
      attribute.attribute_of.should be_empty
      attribute.type.should eq("Lookup")
      attribute.display_name.should eq("Contact")
      attribute.required_level.should eq("None")

      attributes = entities[1].attributes
      attributes.size.should eq(2)
      attribute  = attributes.first
      attribute.logical_name.should eq("customertypecodename")
      attribute.attribute_of.should eq("customertypecode")
      attribute.type.should eq("Virtual")
      attribute.display_name.should be_empty
      attribute.required_level.should eq("None")

      attributes = entities[2].attributes
      attributes.size.should eq(2)
      attribute = attributes.first
      attribute.logical_name.should eq("createdonbehalfbyyominame")
      attribute.attribute_of.should eq("createdonbehalfby")
      attribute.type.should eq("String")
      attribute.display_name.should be_empty
      attribute.required_level.should eq("None")
    end
  end

  describe "#who_am_i" do
    it "returns user information" do
      subject.stub(:post).and_return(fixture("who_am_i_result"))

      response = subject.who_am_i
      response.UserId.should == "1bfa3886-df7e-468c-8435-b5adfb0441ed"
      response.BusinessUnitId.should == "4e87d619-838a-e311-89a7-6c3be5a80184"
      response.OrganizationId.should == "0140d597-e270-494a-89e1-bd0b43774e50"
    end
  end

  describe "#load_entity" do
    it "returns Model::Opportunity" do
      response = subject.load_entity("opportunity", "c4944f99-b5a0-e311-b64f-6c3be5a87df0")
      response.should be_a(DynamicsCRM::Model::Opportunity)
    end

    it "returns Model::Entity" do
      response = subject.load_entity("account", "c4944f99-b5a0-e311-b64f-6c3be5a87df0")
      response.should be_a(DynamicsCRM::Model::Entity)
    end
  end

  describe "#determine_region" do
    context "Client receives only hostname" do
      it "return the correct region" do
        client = DynamicsCRM::Client.new(hostname: 'xunda.api.crm2.dynamics.com')
        expect(client.region).to eq('urn:crmsam:dynamics.com')
      end
    end
    context "Client receives only organization_name" do
      it "return the correct region" do
        client = DynamicsCRM::Client.new(organization_name: 'xunda')
        expect(client.region).to eq('urn:crmna:dynamics.com')
      end
    end
  end

end
