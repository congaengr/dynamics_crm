require 'spec_helper'

describe DynamicsCRM::Metadata::EntityMetadata do

  describe 'initialization' do
    subject {
      doc = REXML::Document.new(fixture("retrieve_all_entities"))
      entity = doc.get_elements("//d:EntityMetadata").first
      DynamicsCRM::Metadata::EntityMetadata.new(entity)
    }

    context "parse attributes according to their type" do
      it { expect(subject.MetadataId).to eq("30b0cd7e-0081-42e1-9a48-688442277fae") }
      it { expect(subject.LogicalName).to eq("opportunity") }
      it { expect(subject.ObjectTypeCode).to eq("3") }
      it { expect(subject.OwnershipType).to eq("UserOwned") }
      it { expect(subject.PrimaryIdAttribute).to eq("opportunityid") }
      it { expect(subject.PrimaryNameAttribute).to eq("name") }
      it { expect(subject.attributes).to eq([]) }
    end

  end

  context 'relationships' do
    subject {
      doc = REXML::Document.new(fixture("retrieve_entity_relationships_response"))
      entity = doc.get_elements("//b:KeyValuePairOfstringanyType/c:value").first
      DynamicsCRM::Metadata::EntityMetadata.new(entity)
    }

    context "parse attributes and relationships according to their type" do
      it { expect(subject.MetadataId).to eq("30b0cd7e-0081-42e1-9a48-688442277fae") }
      it { expect(subject.LogicalName).to eq("opportunity") }
      it { expect(subject.ObjectTypeCode).to eq("3") }
      it { expect(subject.OwnershipType).to eq("UserOwned") }
      it { expect(subject.PrimaryIdAttribute).to eq("opportunityid") }
      it { expect(subject.PrimaryNameAttribute).to eq("name") }
      it { expect(subject.one_to_many.size).to eq 7 }
      it { expect(subject.many_to_many.size).to eq 1 }
      it { expect(subject.many_to_one.size).to eq 8 }
    end

    context "many to one metadata" do
      let(:systemuser) { subject.many_to_one.first }

      it { expect(systemuser.entity.LogicalName).to eq "opportunity" }
      it { expect(systemuser.ReferencedAttribute).to eq 'systemuserid' }
      it { expect(systemuser.ReferencedEntity).to eq 'systemuser' }
      it { expect(systemuser.ReferencingAttribute).to eq 'createdby' }
      it { expect(systemuser.ReferencingEntity).to eq 'opportunity' }

      it { expect(systemuser.link_entity_fragment(["address1_composite", "address1_city"])).to eq %Q{
<link-entity name="systemuser" from="systemuserid" to="createdby" alias="systemuser">
  <attribute name="address1_composite" />
  <attribute name="address1_city" />
</link-entity>
}
      }
    end

    context "one to many metadata" do
      let(:socialactivity) { subject.one_to_many.first }

      it { expect(socialactivity.entity.LogicalName).to eq "opportunity" }
      it { expect(socialactivity.ReferencedAttribute).to eq 'opportunityid' }
      it { expect(socialactivity.ReferencedEntity).to eq 'opportunity' }
      it { expect(socialactivity.ReferencingAttribute).to eq 'regardingobjectid' }
      it { expect(socialactivity.ReferencingEntity).to eq 'socialactivity' }
    end

    context "many to many metadata" do
      let(:competitors) { subject.many_to_many.first }

      it { expect(competitors.entity.LogicalName).to eq "opportunity" }

      it { expect(competitors.SchemaName).to eq "opportunitycompetitors_association" }
      it { expect(competitors.Entity1IntersectAttribute).to eq "opportunityid" }
      it { expect(competitors.Entity1LogicalName).to eq "opportunity" }

      it { expect(competitors.Entity2IntersectAttribute).to eq "competitorid" }
      it { expect(competitors.Entity2LogicalName).to eq "competitor" }
      it { expect(competitors.IntersectEntityName).to eq "opportunitycompetitors" }
    end
  end

end
