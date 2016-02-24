require 'spec_helper'

describe DynamicsCRM::Metadata::RetrieveMetadataChangesResponse do

  describe 'retrieve_metadata_changes_response' do
    subject {
      file = fixture("retrieve_metadata_changes_response")
      DynamicsCRM::Metadata::RetrieveMetadataChangesResponse.new(file)
    }

    it "parses execute result" do
      expect(subject.ResponseName).to eq("RetrieveMetadataChanges")
      expect(subject.entities.size).to eq(3)

      entity = subject.entities[0]
      expect(entity.MetadataId).to eq("e3fe4ff2-a630-49bb-a1e9-debc3a076815")
      expect(entity.LogicalName).to eq("incident")
      attributes = entity.attributes
      expect(attributes).not_to be_nil
      expect(attributes.size).to eq(2)
      expect(attributes.first.logical_name).to eq('contactid')
      expect(attributes.first.display_name).to eq('Contact')
      expect(attributes.first.type).to eq('Lookup')
      expect(attributes.first.attribute_of).to be_empty
      expect(attributes.first.required_level).to eq('None')

      entity = subject.entities[1]
      expect(entity.MetadataId).to eq("608861bc-50a4-4c5f-a02c-21fe1943e2cf")
      expect(entity.LogicalName).to eq("contact")
      attributes = entity.attributes
      expect(attributes).not_to be_nil
      expect(attributes.size).to eq(2)
      expect(attributes.first.logical_name).to eq("customertypecodename")
      expect(attributes.first.attribute_of).to eq("customertypecode")
      expect(attributes.first.display_name).to be_empty
      expect(attributes.first.type).to eq("Virtual")
      expect(attributes.first.required_level).to eq("None")

      entity = subject.entities[2]
      expect(entity.MetadataId).to eq("c1961a14-d4e6-470c-8d1e-23ae6b1bbb8d")
      expect(entity.LogicalName).to eq("annotation")
      attributes = entity.attributes
      expect(attributes).not_to be_nil
      expect(attributes.size).to eq(2)
      expect(attributes.first.logical_name).to eq("createdonbehalfbyyominame")
      expect(attributes.first.attribute_of).to eq("createdonbehalfby")
      expect(attributes.first.display_name).to be_empty
      expect(attributes.first.type).to eq("String")
      expect(attributes.first.required_level).to eq("None")
    end
  end
end
