require 'spec_helper'

describe Mscrm::Soap::Metadata::RetrieveAttributeResponse do

  describe 'retrieve_attribute_response' do
    subject {
      file = fixture("retrieve_attribute_response")
      Mscrm::Soap::Metadata::RetrieveAttributeResponse.new(file)
    }

    context "parse execute result" do
      it { subject.ResponseName.should == "RetrieveAttribute" }
      it { subject.attributes.MetadataId.should == "79194881-c699-e311-9752-6c3be5a87df0" }
      it { subject.attributes.AttributeType.should == "Money" }
      it { subject.attributes.LogicalName.should == "new_value" }
      it { subject.attributes.IsPrimaryId.should == "false" }
      it { subject.attributes.AttributeTypeName.Value.should == "MoneyType" }
      it { subject.attributes.DisplayName.LocalizedLabels.LocalizedLabel.Label.should == "Value" }
    end

  end

  describe '#picklist_attribute_metadata' do
    subject {
      file = fixture("retrieve_attribute_picklist_response")
      Mscrm::Soap::Metadata::RetrieveAttributeResponse.new(file)
    }

    context "parse execute result" do
      it { subject.ResponseName.should == "RetrieveAttribute" }
      it { subject.attributes.MetadataId.should == "ae00233e-70c0-4a1f-803f-03ff723e5440" }
      it { subject.attributes.AttributeType.should == "Picklist" }
      it { subject.attributes.LogicalName.should == "industrycode" }
      it { subject.attributes.EntityLogicalName.should == "account" }
      it { subject.attributes.AttributeTypeName.Value.should == "PicklistType" }
      it { subject.attributes.picklist_options.should include("Accounting", "Business Services") }
    end

  end


end
