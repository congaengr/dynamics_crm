require 'spec_helper'

describe DynamicsCRM::Client do
  let(:subject) { DynamicsCRM::Client.new(organization_name: "tinderboxdev")}

  describe "#authenticate_user" do
    it "authenticates with username and password" do

      subject.stub(:post).and_return(fixture("request_security_token_response"))

      subject.authenticate_user('testing', 'password')

      subject.instance_variable_get("@security_token0").should start_with("tMFpDJbJHcZnRVuby5cYmRbCJo2OgOFLEOrUHj+wz")
      subject.instance_variable_get("@security_token1").should start_with("CX7BFgRnW75tE6GiuRICjeVDV+6q4KDMKLyKmKe9A8U")
      subject.instance_variable_get("@key_identifier").should == "D3xjUG3HGaQuKyuGdTWuf6547Lo="
    end

    it "should raise arugment error when no parameters are passed" do
      expect { subject.authenticate_user() }.to raise_error(ArgumentError)
    end
  end

  describe "#retrieve" do
    it "should retrieve object by id" do

      subject.stub(:post).and_return(fixture("retrieve_account_all_columns"))

      result = subject.retrieve("account", "93f0325c-a592-e311-b7f3-6c3be5a8a0c8")

      result.should be_a(DynamicsCRM::Model::RetrieveResult)
      result.type.should == "account"
      result.id.should == "93f0325c-a592-e311-b7f3-6c3be5a8a0c8"
      result.name.should == "Adventure Works (sample)"
    end
  end

  describe "#retrieve_multiple" do
    it "should retrieve multiple entities by criteria" do

      subject.stub(:post).and_return(fixture("retrieve_multiple_result"))

      result = subject.retrieve_multiple("account", ["name", "Equal", "Test Account"], columns=[])

      result.should be_a(DynamicsCRM::Model::RetrieveMultipleResult)
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

      result.should be_a(DynamicsCRM::Model::CreateResult)
      result.id.should == "c4944f99-b5a0-e311-b64f-6c3be5a87df0"
      result.Id.should == "c4944f99-b5a0-e311-b64f-6c3be5a87df0"
    end
  end

  describe "#update" do
    it "updates entity by id" do

      subject.stub(:post).and_return(fixture("update_response"))

      result = subject.update("account", "c4944f99-b5a0-e311-b64f-6c3be5a87df0", {name: "Adventure Park"})

      result.should be_a(DynamicsCRM::Model::UpdateResult)
    end
  end

  describe "#delete" do
    it "deletes entity by id" do

      subject.stub(:post).and_return(fixture("update_response"))

      result = subject.delete("account", "c4944f99-b5a0-e311-b64f-6c3be5a87df0")

      result.should be_a(DynamicsCRM::Model::DeleteResult)
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


end
