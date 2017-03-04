require 'spec_helper'

describe DynamicsCRM::XML::Criteria do
  describe 'initialization' do
    subject do
      DynamicsCRM::XML::Criteria.new
    end

    it 'generates empty Criteria fragment' do
      expected = %(<a:Criteria>
        <a:Conditions />
        <a:FilterOperator>And</a:FilterOperator>
        <a:Filters />
      </a:Criteria>)

      expect(subject.to_xml).to match_xml(expected)
    end
  end

  describe 'single criteria' do
    subject do
      DynamicsCRM::XML::Criteria.new([['name', 'Equal', 'Test Opp']])
    end
    let(:expected) {
      %(<a:Criteria>
          <a:Conditions>
            <a:ConditionExpression>
              <a:AttributeName>name</a:AttributeName>
              <a:Operator>Equal</a:Operator>
              <a:Values xmlns:d="http://schemas.microsoft.com/2003/10/Serialization/Arrays">
                <d:anyType i:type="s:string" xmlns:s="http://www.w3.org/2001/XMLSchema">Test Opp</d:anyType>
              </a:Values>
            </a:ConditionExpression>
          </a:Conditions>
          <a:FilterOperator>And</a:FilterOperator>
          <a:Filters />
      </a:Criteria>)
    }

    it 'generates Criteria fragment with single ConditionExpression' do
      expect(subject.to_xml).to match_xml expected
    end

    it 'set data type explicitly' do
      # Supports optional fourth value for data type
      subject = DynamicsCRM::XML::Criteria.new([['name', 'Equal', 'Test Opp', 'customstring']])

      expect(subject.to_xml).to match_xml expected.gsub('s:string', 's:customstring')
    end
  end

  describe 'multiple criteria' do
    subject do
      DynamicsCRM::XML::Criteria.new([
        ['name', 'Equal', 'Test Opp'],
        ['salesstage', 'In', [0, 1, 2]],
      ])
    end

    it 'generates Criteria with multiple ConditionExpression(s)' do
      expect(subject.to_xml).to match_xml %(<a:Criteria>
          <a:Conditions>
            <a:ConditionExpression>
              <a:AttributeName>name</a:AttributeName>
              <a:Operator>Equal</a:Operator>
              <a:Values xmlns:d="http://schemas.microsoft.com/2003/10/Serialization/Arrays">
                <d:anyType i:type="s:string" xmlns:s="http://www.w3.org/2001/XMLSchema">Test Opp</d:anyType>
              </a:Values>
            </a:ConditionExpression>
            <a:ConditionExpression>
              <a:AttributeName>salesstage</a:AttributeName>
              <a:Operator>In</a:Operator>
              <a:Values xmlns:d="http://schemas.microsoft.com/2003/10/Serialization/Arrays">
                <d:anyType i:type="s:int" xmlns:s="http://www.w3.org/2001/XMLSchema">0</d:anyType>
                <d:anyType i:type="s:int" xmlns:s="http://www.w3.org/2001/XMLSchema">1</d:anyType>
                <d:anyType i:type="s:int" xmlns:s="http://www.w3.org/2001/XMLSchema">2</d:anyType>
              </a:Values>
            </a:ConditionExpression>
          </a:Conditions>
          <a:FilterOperator>And</a:FilterOperator>
          <a:Filters />
      </a:Criteria>)
    end
  end
end
