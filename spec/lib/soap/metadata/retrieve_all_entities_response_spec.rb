require 'spec_helper'

describe Mscrm::Soap::Metadata::RetrieveAllEntitiesResponse do

  describe 'retrieve_all_entities' do
    subject {
      file = fixture("retrieve_all_entities")
      Mscrm::Soap::Metadata::RetrieveAllEntitiesResponse.new(file)
    }

    context "parse execute result" do
      let(:opportunity) { subject.entities.first }
      it { subject.ResponseName.should == "RetrieveAllEntities" }
      it { subject.entities.size.should == 3 }
      it { opportunity.MetadataId.should == "30b0cd7e-0081-42e1-9a48-688442277fae" }
      it { opportunity.LogicalName.should == "opportunity" }
      it { opportunity.ObjectTypeCode.should == "3" }
      it { opportunity.OwnershipType.should == "UserOwned" }
      it { opportunity.PrimaryIdAttribute.should == "opportunityid" }
      it { opportunity.PrimaryNameAttribute.should == "name" }

    end

  end

end
