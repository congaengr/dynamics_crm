require 'spec_helper'

describe DynamicsCRM::Metadata::RetrieveEntityResponse do

  describe 'retrieve_entity_response' do
    subject {
      file = fixture("retrieve_entity_response")
      DynamicsCRM::Metadata::RetrieveEntityResponse.new(file)
    }

    context "parse execute result" do
      it { subject.ResponseName.should == "RetrieveEntity" }
      it { subject.entity.MetadataId.should == "30b0cd7e-0081-42e1-9a48-688442277fae" }
      it { subject.entity.LogicalName.should == "opportunity" }
      it { subject.entity.ObjectTypeCode.should == "3" }
      it { subject.entity.OwnershipType.should == "UserOwned" }
      it { subject.entity.PrimaryIdAttribute.should == "opportunityid" }
      it { subject.entity.PrimaryNameAttribute.should == "name" }

    end

  end

end
