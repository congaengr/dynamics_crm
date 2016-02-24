require 'spec_helper'

describe DynamicsCRM::Metadata::RetrieveAttributeResponse do

  describe 'retrieve_attribute_response' do
    subject {
      file = fixture("retrieve_attribute_response")
      DynamicsCRM::Metadata::RetrieveAttributeResponse.new(file)
    }

    context "parse execute result" do
      it { expect(subject.ResponseName).to eq("RetrieveAttribute") }
      it { expect(subject.attribute.MetadataId).to eq("79194881-c699-e311-9752-6c3be5a87df0") }
      it { expect(subject.attribute.AttributeType).to eq("Money") }
      it { expect(subject.attribute.LogicalName).to eq("new_value") }
      it { expect(subject.attribute.IsPrimaryId).to eq("false") }
      it { expect(subject.attribute.AttributeTypeName.Value).to eq("MoneyType") }
      it { expect(subject.attribute.DisplayName.LocalizedLabels.LocalizedLabel.Label).to eq("Value") }
    end

  end

  describe '#picklist_attribute_metadata' do
    subject {
      file = fixture("retrieve_attribute_picklist_response")
      DynamicsCRM::Metadata::RetrieveAttributeResponse.new(file)
    }

    context "parse execute result" do
      it { expect(subject.ResponseName).to eq("RetrieveAttribute") }
      it { expect(subject.attribute.MetadataId).to eq("ae00233e-70c0-4a1f-803f-03ff723e5440") }
      it { expect(subject.attribute.AttributeType).to eq("Picklist") }
      it { expect(subject.attribute.LogicalName).to eq("industrycode") }
      it { expect(subject.attribute.EntityLogicalName).to eq("account") }
      it { expect(subject.attribute.AttributeTypeName.Value).to eq("PicklistType") }
      it { expect(subject.attribute.picklist_options).to be_a(Hash) }
      it {
        expect(subject.attribute.picklist_options).to have_key(1)
        expect(subject.attribute.picklist_options[1]).to eq("Accounting")
      }
      it {
        expect(subject.attribute.picklist_options).to have_key(33)
        expect(subject.attribute.picklist_options[33]).to eq("Wholesale")
      }
    end

  end

  describe '#identifier_attribute_metadata' do
    subject {
      file = fixture("retrieve_attribute_identifier_response")
      DynamicsCRM::Metadata::RetrieveAttributeResponse.new(file)
    }

    context "parse execute result" do
      it { expect(subject.ResponseName).to eq("RetrieveAttribute") }
      it { expect(subject.attribute.MetadataId).to eq("f8cd5db9-cee8-4845-8cdd-cd4f504957e7") }
      it { expect(subject.attribute.AttributeType).to eq("Uniqueidentifier") }
      it { expect(subject.attribute.LogicalName).to eq("accountid") }
      it { expect(subject.attribute.EntityLogicalName).to eq("account") }
    end

  end

end
