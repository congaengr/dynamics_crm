require 'spec_helper'

describe DynamicsCRM::XML::Entity do

  describe 'initialization' do
    subject {
      DynamicsCRM::XML::Entity.new("account")
    }

    context "default instance" do
      it { subject.logical_name.should == "account" }
      it { subject.id.should == "00000000-0000-0000-0000-000000000000" }
      it { subject.attributes.should be_nil }
      it { subject.entity_state.should be_nil }
      it { subject.formatted_values.should be_nil }
      it { subject.related_entities.should be_nil }
    end

    context "#to_xml" do
      it { subject.to_xml.should include("<a:Id>00000000-0000-0000-0000-000000000000</a:Id>") }
      it { subject.to_xml.should include("<a:LogicalName>account</a:LogicalName>") }
    end

  end

  describe '#from_xml' do

    subject {
      document = REXML::Document.new(fixture("retrieve_multiple_result"))
      entity_xml = document.get_elements("//b:Entity").first
     DynamicsCRM::XML::Entity.from_xml(entity_xml)
    }

    context "parses XML document into instance variables" do
      it { subject.id.should == "7bf2e032-ad92-e311-9752-6c3be5a87df0" }
      it { subject.attributes.should == {"accountid" => "7bf2e032-ad92-e311-9752-6c3be5a87df0"} }
      it { subject.entity_state.should be_nil }
      it { subject.formatted_values.should be_nil }
      it { subject.logical_name.should == "account" }
      it { subject.related_entities.should be_nil }
    end
  end 

end
