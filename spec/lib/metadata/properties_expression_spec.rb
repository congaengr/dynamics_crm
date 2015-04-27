require 'spec_helper'

describe DynamicsCRM::Metadata::PropertiesExpression do

  describe 'initialization' do
    subject {
      DynamicsCRM::Metadata::PropertiesExpression.new(["LogicalName","AttributeType","DisplayName","Description"])
    }

    context "generate properties expression XML" do
      it { subject.to_xml({namespace: 'd'}).should include("<d:AllProperties>false</d:AllProperties>") }
      it { subject.to_xml.should include("<AllProperties>false</AllProperties>") }
      it { subject.to_xml.should include("<e:string>LogicalName</e:string>") }
      it { subject.to_xml.should include("<e:string>AttributeType</e:string>") }
      it { subject.to_xml.should include("<e:string>DisplayName</e:string>") }
      it { subject.to_xml.should include("<e:string>Description</e:string>") }
    end
  end
end
