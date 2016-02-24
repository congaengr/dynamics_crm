require 'spec_helper'

describe DynamicsCRM::Metadata::AttributeQueryExpression do

  describe 'initialization' do
    subject {
      attribute_filter = DynamicsCRM::Metadata::FilterExpression.new('And')
      attribute_filter.add_condition(['IsCustomAttribute', 'Equals', true])
      attribute_properties = DynamicsCRM::Metadata::PropertiesExpression.new(['LogicalName', 'AttributeType', 'DisplayName'])
      DynamicsCRM::Metadata::AttributeQueryExpression.new(attribute_filter, attribute_properties)
    }

    context "generate attribute query expression" do
      it { expect(subject.to_xml).to include("<b:AttributeQuery>") }
      it { expect(subject.to_xml).to include("<b:MetadataConditionExpression>") }
      it { expect(subject.to_xml).to include("<b:PropertyName>IsCustomAttribute</b:PropertyName>") }
      it { expect(subject.to_xml).to include("<b:ConditionOperator>Equals</b:ConditionOperator>") }
      it { expect(subject.to_xml).to match(/<b:Value i:type='e:boolean' (.*)>true<\/b:Value>/) }
      it { expect(subject.to_xml).to include("<b:FilterOperator>And</b:FilterOperator>") }
      it { expect(subject.to_xml).to include("<b:Properties>") }
      it { expect(subject.to_xml).to include("<b:AllProperties>false</b:AllProperties>") }
      it { expect(subject.to_xml).to include("<b:PropertyNames ") }
      it { expect(subject.to_xml).to include("<e:string>LogicalName</e:string>") }
      it { expect(subject.to_xml).to include("<e:string>AttributeType</e:string>") }
      it { expect(subject.to_xml).to include("<e:string>DisplayName</e:string>") }
    end

  end
end
