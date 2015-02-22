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
      it { subject.to_xml.should include("<b:AttributeQuery>") }
      it { subject.to_xml.should include("<b:MetadataConditionExpression>") }
      it { subject.to_xml.should include("<b:PropertyName>IsCustomAttribute</b:PropertyName>") }
      it { subject.to_xml.should include("<b:ConditionOperator>Equals</b:ConditionOperator>") }
      it { subject.to_xml.should match(/<b:Value i:type='e:boolean' (.*)>true<\/b:Value>/) }
      it { subject.to_xml.should include("<b:FilterOperator>And</b:FilterOperator>") }
      it { subject.to_xml.should include("<b:Properties>") }
      it { subject.to_xml.should include("<b:AllProperties>false</b:AllProperties>") }
      it { subject.to_xml.should include("<b:PropertyNames ") }
      it { subject.to_xml.should include("<e:string>LogicalName</e:string>") }
      it { subject.to_xml.should include("<e:string>AttributeType</e:string>") }
      it { subject.to_xml.should include("<e:string>DisplayName</e:string>") }
    end

  end
end
