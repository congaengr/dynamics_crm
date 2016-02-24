require 'spec_helper'

describe DynamicsCRM::Metadata::RetrieveEntityResponse do

  describe 'retrieve_entity_response' do
    subject {
      file = fixture("retrieve_entity_response")
      DynamicsCRM::Metadata::RetrieveEntityResponse.new(file)
    }

    context "parse execute result" do
      it { expect(subject.ResponseName).to eq("RetrieveEntity") }
      it { expect(subject.entity.MetadataId).to eq("30b0cd7e-0081-42e1-9a48-688442277fae") }
      it { expect(subject.entity.LogicalName).to eq("opportunity") }
      it { expect(subject.entity.ObjectTypeCode).to eq("3") }
      it { expect(subject.entity.OwnershipType).to eq("UserOwned") }
      it { expect(subject.entity.PrimaryIdAttribute).to eq("opportunityid") }
      it { expect(subject.entity.PrimaryNameAttribute).to eq("name") }

    end

  end

end
