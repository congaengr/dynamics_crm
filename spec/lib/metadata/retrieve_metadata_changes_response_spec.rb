require 'spec_helper'

describe DynamicsCRM::Metadata::RetrieveMetadataChangesResponse do

  describe 'retrieve_metadata_changes_response' do
    subject {
      file = fixture("retrieve_metadata_changes_response")
      DynamicsCRM::Metadata::RetrieveMetadataChangesResponse.new(file)
    }

    it "parses execute result" do
      subject.ResponseName.should eq("RetrieveMetadataChanges")
      subject.entities.size.should eq(3)

      entity = subject.entities[0]
      entity.MetadataId.should eq("e3fe4ff2-a630-49bb-a1e9-debc3a076815")
      entity.LogicalName.should eq("incident")
      attributes = entity.attributes
      attributes.should_not be_nil
      attributes.size.should eq(2)
      attributes.first.logical_name.should eq('contactid')
      attributes.first.display_name.should eq('Contact')
      attributes.first.type.should eq('Lookup')
      attributes.first.attribute_of.should be_empty
      attributes.first.required_level.should eq('None')

      entity = subject.entities[1]
      entity.MetadataId.should eq("608861bc-50a4-4c5f-a02c-21fe1943e2cf")
      entity.LogicalName.should eq("contact")
      attributes = entity.attributes
      attributes.should_not be_nil
      attributes.size.should eq(2)
      attributes.first.logical_name.should eq("customertypecodename")
      attributes.first.attribute_of.should eq("customertypecode")
      attributes.first.display_name.should be_empty
      attributes.first.type.should eq("Virtual")
      attributes.first.required_level.should eq("None")

      entity = subject.entities[2]
      entity.MetadataId.should eq("c1961a14-d4e6-470c-8d1e-23ae6b1bbb8d")
      entity.LogicalName.should eq("annotation")
      attributes = entity.attributes
      attributes.should_not be_nil
      attributes.size.should eq(2)
      attributes.first.logical_name.should eq("createdonbehalfbyyominame")
      attributes.first.attribute_of.should eq("createdonbehalfby")
      attributes.first.display_name.should be_empty
      attributes.first.type.should eq("String")
      attributes.first.required_level.should eq("None")
    end
  end
end
