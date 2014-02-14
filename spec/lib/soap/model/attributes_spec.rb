require 'spec_helper'

describe Mscrm::Soap::Model::Attributes do

  describe 'initialization' do
    subject {
      Mscrm::Soap::Model::Attributes.new({
        "telephone1" => "123-213-1234",
        "modifiedon" => Time.now,
        "donotemail" => true,
        "id" => "1bfa3886-df7e-468c-8435-b5adfb0441ed",
        "reference" => {"Id" => "someid", "Name" => "entityname", "LogicalName" => "opportunity"}
        })
    }

    context "parse attributes according to their type" do
      it { subject.to_xml.should include("telephone1") }
      it { subject.to_xml.should include("donotemail") }
      it { subject.to_xml.should include("modifiedon") }
    end

  end

end
