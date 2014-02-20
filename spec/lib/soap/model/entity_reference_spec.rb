require 'spec_helper'

describe Mscrm::Soap::Model::EntityReference do

  describe 'initialization' do
    subject {
      Mscrm::Soap::Model::EntityReference.new("opportunity", "9BF1325C-A592-E311-B7F3-6C3BE5A8A0C8")
    }

    context "default instance" do
      it { subject.logical_name.should == "opportunity" }
      it { subject.id.should == "9BF1325C-A592-E311-B7F3-6C3BE5A8A0C8" }
      it { subject.name.should be_nil }
    end

    context "#to_xml" do
      it {
        # Spacing here is intentional to match created string.
        expected_xml = %Q{
          <entityReference>
            <LogicalName>opportunity</LogicalName>
            <Id>9BF1325C-A592-E311-B7F3-6C3BE5A8A0C8</Id>
            <Name #{@name ? '' : 'nil="true"'}>#{@name}</Name>
          </entityReference>
          }
        subject.to_xml.should == expected_xml
      }
    end

  end

end
