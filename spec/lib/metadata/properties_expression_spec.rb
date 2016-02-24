require 'spec_helper'

describe DynamicsCRM::Metadata::PropertiesExpression do

  describe 'initialization' do
    subject {
      DynamicsCRM::Metadata::PropertiesExpression.new(["LogicalName","AttributeType","DisplayName","Description"])
    }

    context "generate properties expression XML" do
      it { expect(subject.to_xml({namespace: 'd'})).to include("<d:AllProperties>false</d:AllProperties>") }
      it { expect(subject.to_xml).to include("<AllProperties>false</AllProperties>") }
      it { expect(subject.to_xml).to include("<e:string>LogicalName</e:string>") }
      it { expect(subject.to_xml).to include("<e:string>AttributeType</e:string>") }
      it { expect(subject.to_xml).to include("<e:string>DisplayName</e:string>") }
      it { expect(subject.to_xml).to include("<e:string>Description</e:string>") }
    end
  end
end
