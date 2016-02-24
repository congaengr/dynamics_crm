require 'spec_helper'

describe DynamicsCRM::XML::Query do

  describe 'initialization' do
    subject {
      DynamicsCRM::XML::Query.new('opportunity')
    }

    context "generate empty Query fragment" do
      it { expect(subject.to_xml).to include("<b:ColumnSet ") }
      it { expect(subject.to_xml).to match(/<b:Conditions>\s+<\/b:Conditions>/) }
      it { expect(subject.to_xml).to include("<b:AllColumns>true</b:AllColumns>") }
      it { expect(subject.to_xml).to include("<b:Distinct>false</b:Distinct>") }
      it { expect(subject.to_xml).to include("<b:EntityName>opportunity</b:EntityName>") }
      it { expect(subject.to_xml).to include("<b:FilterOperator>And</b:FilterOperator>") }
    end

  end


  describe 'criteria' do
    subject {
      query = DynamicsCRM::XML::Query.new('opportunity')
      query.criteria = DynamicsCRM::XML::Criteria.new([["name", "Equal", "Test Opp"]])
      query
    }

    context "generate empty Query fragment" do
      it { expect(subject.to_xml).to include("<b:ColumnSet ") }
      it { expect(subject.to_xml).to include("<b:ConditionExpression") }
      it { expect(subject.to_xml).to include("AttributeName>name</") }
      it { expect(subject.to_xml).to include("Operator>Equal</") }
      it { expect(subject.to_xml).to include('<d:anyType i:type="s:string" xmlns:s="http://www.w3.org/2001/XMLSchema">Test Opp</d:anyType>') }
      it { expect(subject.to_xml).to include("<b:AllColumns>true</b:AllColumns>") }
      it { expect(subject.to_xml).to include("<b:Distinct>false</b:Distinct>") }
      it { expect(subject.to_xml).to include("<b:EntityName>opportunity</b:EntityName>") }
      it { expect(subject.to_xml).to include("<b:FilterOperator>And</b:FilterOperator>") }
    end

  end

end
