require 'spec_helper'

describe DynamicsCRM::Metadata::FilterExpression do

  describe 'initialization' do

    context "generate OR filter expression XML" do
      subject {
        filter = DynamicsCRM::Metadata::FilterExpression.new('Or')
        filter.add_condition(['SchemaName', 'Equals', 'Contact'])
        filter.add_condition(['SchemaName', 'Equals', 'Annotation'])
        filter.add_condition(['SchemaName', 'Equals', 'Incident'])
        filter
      }

      it { subject.to_xml.should include("<a:MetadataConditionExpression>") }
      it { subject.to_xml.should include("<a:PropertyName>SchemaName</a:PropertyName>") }
      it { subject.to_xml.should include("<a:ConditionOperator>Equals</a:ConditionOperator>") }
      it { subject.to_xml.should match(/<a:Value(.*)>Contact<\/a:Value>/) }
      it { subject.to_xml.should match(/<a:Value(.*)>Annotation<\/a:Value>/) }
      it { subject.to_xml.should match(/<a:Value(.*)>Incident<\/a:Value>/) }
      it { subject.to_xml.should include("<a:FilterOperator>Or</a:FilterOperator>") }
    end

    context "generate AND filter expression XML" do
      subject {
        filter = DynamicsCRM::Metadata::FilterExpression.new('And')
        filter.add_condition(['SchemaName', 'Equals', 'Contact'])
        filter.add_condition(['SchemaName', 'Equals', 'Annotation'])
        filter.add_condition(['SchemaName', 'Equals', 'Incident'])
        filter
      }

      it { subject.to_xml.should include("<a:MetadataConditionExpression>") }
      it { subject.to_xml.should include("<a:PropertyName>SchemaName</a:PropertyName>") }
      it { subject.to_xml.should include("<a:ConditionOperator>Equals</a:ConditionOperator>") }
      it { subject.to_xml.should match(/<a:Value(.*)>Contact<\/a:Value>/) }
      it { subject.to_xml.should match(/<a:Value(.*)>Annotation<\/a:Value>/) }
      it { subject.to_xml.should match(/<a:Value(.*)>Incident<\/a:Value>/) }
      it { subject.to_xml.should include("<a:FilterOperator>And</a:FilterOperator>") }
    end

  end
end
