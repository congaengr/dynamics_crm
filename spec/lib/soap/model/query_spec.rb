require 'spec_helper'

describe Mscrm::Soap::Model::Query do

  describe 'initialization' do
    subject {
      Mscrm::Soap::Model::Query.new('opportunity')
    }

    context "generate empty Query fragment" do
      it { subject.to_xml.should include("<b:ColumnSet ") }
      it { subject.to_xml.should match(/<b:Conditions>\s+<\/b:Conditions>/) }
      it { subject.to_xml.should include("<b:AllColumns>true</b:AllColumns>") }
      it { subject.to_xml.should include("<b:Distinct>false</b:Distinct>") }
      it { subject.to_xml.should include("<b:EntityName>opportunity</b:EntityName>") }
      it { subject.to_xml.should include("<b:FilterOperator>And</b:FilterOperator>") }
    end

  end


  describe 'criteria' do
    subject {
      query = Mscrm::Soap::Model::Query.new('opportunity')
      query.criteria = Mscrm::Soap::Model::Criteria.new([["name", "Equal", "Test Opp"]])
      query
    }

    context "generate empty Query fragment" do
      it { subject.to_xml.should include("<b:ColumnSet ") }
      it { subject.to_xml.should include("<b:ConditionExpression") }
      it { subject.to_xml.should include("AttributeName>name</") }
      it { subject.to_xml.should include("Operator>Equal</") }
      it { subject.to_xml.should include('<d:anyType i:type="s:string" xmlns:s="http://www.w3.org/2001/XMLSchema">Test Opp</d:anyType>') }
      it { subject.to_xml.should include("<b:AllColumns>true</b:AllColumns>") }
      it { subject.to_xml.should include("<b:Distinct>false</b:Distinct>") }
      it { subject.to_xml.should include("<b:EntityName>opportunity</b:EntityName>") }
      it { subject.to_xml.should include("<b:FilterOperator>And</b:FilterOperator>") }
    end

  end

end
