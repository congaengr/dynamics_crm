require 'spec_helper'

describe DynamicsCRM::Metadata::RetrieveAllEntitiesResponse do

  describe 'retrieve_all_entities' do
    subject {
      file = fixture("retrieve_all_entities")
      DynamicsCRM::Metadata::RetrieveAllEntitiesResponse.new(file)
    }

    context "parse execute result" do
      let(:opportunity) { subject.entities.first }
      it { expect(subject.ResponseName).to eq("RetrieveAllEntities") }
      it { expect(subject.entities.size).to eq(3) }
      it { expect(opportunity.MetadataId).to eq("30b0cd7e-0081-42e1-9a48-688442277fae") }
      it { expect(opportunity.LogicalName).to eq("opportunity") }
      it { expect(opportunity.ObjectTypeCode).to eq("3") }
      it { expect(opportunity.OwnershipType).to eq("UserOwned") }
      it { expect(opportunity.PrimaryIdAttribute).to eq("opportunityid") }
      it { expect(opportunity.PrimaryNameAttribute).to eq("name") }

    end

  end

end
