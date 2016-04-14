require 'spec_helper'

describe DynamicsCRM::XML::Entity do

  describe 'initialization' do
    subject {
      DynamicsCRM::XML::Entity.new("account")
    }

    context "default instance" do
      it { expect(subject.logical_name).to eq("account") }
      it { expect(subject.id).to eq("00000000-0000-0000-0000-000000000000") }
      it { expect(subject.attributes).to be_nil }
      it { expect(subject.entity_state).to be_nil }
      it { expect(subject.formatted_values).to be_nil }
      it { expect(subject.related_entities).to be_nil }
    end

    context "#to_xml" do
      it { expect(subject.to_xml).to include("<a:Id>00000000-0000-0000-0000-000000000000</a:Id>") }
      it { expect(subject.to_xml).to include("<a:LogicalName>account</a:LogicalName>") }
    end

  end

  describe "entity with attributes" do
    subject {
      entity = DynamicsCRM::XML::Entity.new("opportunity")
      entity.attributes = DynamicsCRM::XML::Attributes.new(
        opportunityid: DynamicsCRM::XML::EntityReference.new("opportunity", "2dc8d7bb-149f-e311-ba8d-6c3be5a8ad64")
      )
      entity
    }

    context "#to_xml" do
      # Contains nested Attributes with EntityReference
      it { expect(subject.to_xml).to include('<c:value i:type="a:EntityReference">') }
      it { expect(subject.to_xml).to include("<a:Id>2dc8d7bb-149f-e311-ba8d-6c3be5a8ad64</a:Id>") }
      it { expect(subject.to_xml).to include("<a:LogicalName>opportunity</a:LogicalName>") }
      it { expect(subject.to_xml).to include("<a:Id>00000000-0000-0000-0000-000000000000</a:Id>") }
    end

  end

  describe '#from_xml' do

    subject {
      document = REXML::Document.new(fixture("retrieve_multiple_result"))
      entity_xml = document.get_elements("//b:Entity").first
      DynamicsCRM::XML::Entity.from_xml(entity_xml)
    }

    context "parses XML document into instance variables" do
      it { expect(subject.id).to eq("7bf2e032-ad92-e311-9752-6c3be5a87df0") }
      it { expect(subject.attributes).to eq({"accountid" => "7bf2e032-ad92-e311-9752-6c3be5a87df0"}) }
      it { expect(subject.entity_state).to be_nil }
      it { expect(subject.formatted_values).to be_nil }
      it { expect(subject.logical_name).to eq("account") }
      it { expect(subject.related_entities).to be_nil }
    end
  end

  describe "entity with array" do
    subject {
      entity = DynamicsCRM::XML::Entity.new("activityparty")
      entity.attributes = DynamicsCRM::XML::Attributes.new(
          partyid: DynamicsCRM::XML::EntityReference.new("systemuser", "f36aa96c-e7a5-4c70-8254-47c8ba947561")
      )
      entity
    }

    context "#to_xml" do
      it { expect(DynamicsCRM::XML::Attributes.new({to: [subject]}).to_xml).to include('<c:value i:type="a:ArrayOfEntity">') }
    end
  end

end
