require 'spec_helper'

describe Mscrm::Soap::Metadata::EntityMetadata do

  describe 'initialization' do
    subject {
      doc = REXML::Document.new(fixture("retrieve_all_entities"))
      entity = doc.get_elements("//d:EntityMetadata").first
      Mscrm::Soap::Metadata::EntityMetadata.new(entity)
    }

    context "parse attributes according to their type" do
      it { subject.MetadataId.should == "30b0cd7e-0081-42e1-9a48-688442277fae" }
      it { subject.LogicalName.should == "opportunity" }
      it { subject.ObjectTypeCode.should == "3" }
      it { subject.OwnershipType.should == "UserOwned" }
      it { subject.PrimaryIdAttribute.should == "opportunityid" }
      it { subject.PrimaryNameAttribute.should == "name" }
    end

  end

end
