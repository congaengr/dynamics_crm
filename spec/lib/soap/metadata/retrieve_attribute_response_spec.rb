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

end
