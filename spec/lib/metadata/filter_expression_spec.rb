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

      it { expect(subject.to_xml).to include("<a:MetadataConditionExpression>") }
      it { expect(subject.to_xml).to include("<a:PropertyName>SchemaName</a:PropertyName>") }
      it { expect(subject.to_xml).to include("<a:ConditionOperator>Equals</a:ConditionOperator>") }
      it { expect(subject.to_xml).to match(/<a:Value(.*)>Contact<\/a:Value>/) }
      it { expect(subject.to_xml).to match(/<a:Value(.*)>Annotation<\/a:Value>/) }
      it { expect(subject.to_xml).to match(/<a:Value(.*)>Incident<\/a:Value>/) }
      it { expect(subject.to_xml).to include("<a:FilterOperator>Or</a:FilterOperator>") }
    end

    context "generate AND filter expression XML" do
      subject {
        filter = DynamicsCRM::Metadata::FilterExpression.new('And')
        filter.add_condition(['SchemaName', 'Equals', 'Contact'])
        filter.add_condition(['SchemaName', 'Equals', 'Annotation'])
        filter.add_condition(['SchemaName', 'Equals', 'Incident'])
        filter
      }

      it { expect(subject.to_xml).to include("<a:MetadataConditionExpression>") }
      it { expect(subject.to_xml).to include("<a:PropertyName>SchemaName</a:PropertyName>") }
      it { expect(subject.to_xml).to include("<a:ConditionOperator>Equals</a:ConditionOperator>") }
      it { expect(subject.to_xml).to match(/<a:Value(.*)>Contact<\/a:Value>/) }
      it { expect(subject.to_xml).to match(/<a:Value(.*)>Annotation<\/a:Value>/) }
      it { expect(subject.to_xml).to match(/<a:Value(.*)>Incident<\/a:Value>/) }
      it { expect(subject.to_xml).to include("<a:FilterOperator>And</a:FilterOperator>") }
    end

  end
end
