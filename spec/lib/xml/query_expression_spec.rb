require 'spec_helper'

describe DynamicsCRM::XML::QueryExpression do

  describe 'initialization' do
    subject {
      DynamicsCRM::XML::QueryExpression.new('opportunity')
    }

    context "generate empty QueryExpression fragment" do
      it { expect(subject.to_xml).to include("<b:ColumnSet ") }
      it { expect(subject.to_xml).to include("<b:Criteria>") }
      it { expect(subject.to_xml).to include("<b:Conditions />") }
      it { expect(subject.to_xml).to include("<b:AllColumns>true</b:AllColumns>") }
      it { expect(subject.to_xml).to include("<b:Distinct>false</b:Distinct>") }
      it { expect(subject.to_xml).to include("<b:EntityName>opportunity</b:EntityName>") }
      it { expect(subject.to_xml).to include("<b:FilterOperator>And</b:FilterOperator>").or(include("<b:FilterOperator>Or</b:FilterOperator>")) }
    end
  end

  describe 'Criteria' do
    subject {
      query = DynamicsCRM::XML::QueryExpression.new('opportunity')
      query.criteria = DynamicsCRM::XML::Criteria.new([["name", "Equal", "Test Opp"]])
      query
    }

    context "generate QueryExpression fragment" do
      it { expect(subject.to_xml).to include("<b:ColumnSet ") }
      it { expect(subject.to_xml).to include("<b:ConditionExpression") }
      it { expect(subject.to_xml).to include("AttributeName>name</") }
      it { expect(subject.to_xml).to include("Operator>Equal</") }
      it { expect(subject.to_xml).to include('<d:anyType i:type="s:string" xmlns:s="http://www.w3.org/2001/XMLSchema">Test Opp</d:anyType>') }
      it { expect(subject.to_xml).to include("<b:AllColumns>true</b:AllColumns>") }
      it { expect(subject.to_xml).to include("<b:Distinct>false</b:Distinct>") }
      it { expect(subject.to_xml).to include("<b:EntityName>opportunity</b:EntityName>") }
      it { expect(subject.to_xml).to include("<b:FilterOperator>And</b:FilterOperator>").or(include("<b:FilterOperator>Or</b:FilterOperator>")) }
    end
  end

  describe 'PageInfo' do
    subject {
      query = DynamicsCRM::XML::QueryExpression.new('account')
      query.columns = %w(accountid name)
      query.criteria.add_condition('name', 'NotEqual', 'Test Account')
      query.page_info = DynamicsCRM::XML::PageInfo.new(count: 5, page_number: 2, return_total_record_count: true)
      query
    }

    context "generate empty QueryExpression fragment" do
      it { expect(subject.to_xml).to include('<b:ColumnSet ') }
      it { expect(subject.to_xml).to include('<b:ConditionExpression') }
      it { expect(subject.to_xml).to include('AttributeName>name</') }
      it { expect(subject.to_xml).to include('Operator>NotEqual</') }
      it { expect(subject.to_xml).to include('<d:anyType i:type="s:string" xmlns:s="http://www.w3.org/2001/XMLSchema">Test Account</d:anyType>') }
      it { expect(subject.to_xml).to include('<b:AllColumns>false</b:AllColumns>') }
      it { expect(subject.to_xml).to include('<b:Columns') }
      it { expect(subject.to_xml).to include('<b:EntityName>account</b:EntityName>') }
      it { expect(subject.to_xml).to include('<b:PageInfo>') }
      it { expect(subject.to_xml).to include('<b:Count>5</b:Count>') }
      it { expect(subject.to_xml).to include('<b:PageNumber>2</b:PageNumber>') }
      it { expect(subject.to_xml).to include('<b:ReturnTotalRecordCount>true</b:ReturnTotalRecordCount>') }
    end
  end
end
