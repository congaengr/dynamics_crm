require 'spec_helper'

describe DynamicsCRM::Client do
  let(:subject) { DynamicsCRM::Client.new(organization_name: "tinderboxdev")}

  describe "#authenticate" do
    it "authenticates with username and password" do

      subject.stub(:post).and_return(fixture("request_security_token_response"))

      subject.authenticate('testing', 'password')

      subject.instance_variable_get("@security_token0").should start_with("tMFpDJbJHcZnRVuby5cYmRbCJo2OgOFLEOrUHj+wz")
      subject.instance_variable_get("@security_token1").should start_with("CX7BFgRnW75tE6GiuRICjeVDV+6q4KDMKLyKmKe9A8U")
      subject.instance_variable_get("@key_identifier").should == "D3xjUG3HGaQuKyuGdTWuf6547Lo="
    end

    it "should raise arugment error when no parameters are passed" do
      expect { subject.authenticate() }.to raise_error(ArgumentError)
    end

    # This is only method in this suite that actually sends a POST message to Dynamics.
    # This covers the post() and fault parsing logic.
    it "should fail to authenticate with invalid credentials" do
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

  describe "#retrieve" do
    it "should retrieve object by id" do

      subject.stub(:post).and_return(fixture("retrieve_account_all_columns"))

      result = subject.retrieve("account", "93f0325c-a592-e311-b7f3-6c3be5a8a0c8")

      result.should be_a(DynamicsCRM::Response::RetrieveResult)
      result.type.should == "account"
      result.id.should == "93f0325c-a592-e311-b7f3-6c3be5a8a0c8"
      result.name.should == "Adventure Works (sample)"
    end
  end

  describe "#retrieve_multiple" do
    it "should retrieve multiple entities by criteria" do

      subject.stub(:post).and_return(fixture("retrieve_multiple_result"))

      result = subject.retrieve_multiple("account", ["name", "Equal", "Test Account"], columns=[])

      result.should be_a(DynamicsCRM::Response::RetrieveMultipleResult)
      result.entities.size.should == 3
      entities = result.entities

      entities[0].logical_name == "account"
      entities[0].id.should == "7bf2e032-ad92-e311-9752-6c3be5a87df0"
      entities[0].attributes["accountid"].should == "7bf2e032-ad92-e311-9752-6c3be5a87df0"

      entities[1].attributes["accountid"].should == "dbe9d7c9-2c98-e311-9752-6c3be5a87df0"
      entities[2].attributes["accountid"].should == "8ff0325c-a592-e311-b7f3-6c3be5a8a0c8"
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

  describe "#who_am_i" do
    it "returns user information" do
      subject.stub(:post).and_return(fixture("who_am_i_result"))

      response = subject.who_am_i
      response.UserId.should == "1bfa3886-df7e-468c-8435-b5adfb0441ed"
      response.BusinessUnitId.should == "4e87d619-838a-e311-89a7-6c3be5a80184"
      response.OrganizationId.should == "0140d597-e270-494a-89e1-bd0b43774e50"
    end
  end

end
