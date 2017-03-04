require 'spec_helper'

describe DynamicsCRM::XML::FilterExpression do
  describe 'initialization' do
    subject {
      DynamicsCRM::XML::FilterExpression.new('And')
    }

    it 'generates empty FilterExpression fragment' do
      fragment = %(<b:FilterExpression>
                    <b:Conditions />
                    <b:FilterOperator>And</b:FilterOperator>
                    <b:Filters />
                  </b:FilterExpression>)

      expect(subject.to_xml).to match_xml fragment
    end

    it 'generates FilterExpression with condition' do
      subject.add_condition('name', 'Equal', 'Integration Specialists')

      fragment = %(
        <b:FilterExpression>
          <b:Conditions>
            <b:ConditionExpression>
              <b:AttributeName>name</b:AttributeName>
              <b:Operator>Equal</b:Operator>
              <b:Values xmlns:d="http://schemas.microsoft.com/2003/10/Serialization/Arrays">
                <d:anyType i:type="s:string" xmlns:s="http://www.w3.org/2001/XMLSchema">Integration Specialists</d:anyType>
              </b:Values>
            </b:ConditionExpression>
          </b:Conditions>
          <b:FilterOperator>And</b:FilterOperator>
          <b:Filters />
        </b:FilterExpression>)

      expect(subject.to_xml(namespace: 'b')).to match_xml fragment
    end

    it 'generates FilterExpression with sub-Filter' do
      subject.add_condition('name', 'Equal', 'Integration Specialists')

      filter = DynamicsCRM::XML::FilterExpression.new('And')
      filter.add_condition('name', 'NotEqual', 'Bob')

      subject.add_filter(filter)

      fragment = %(
        <b:FilterExpression>
          <b:Conditions>
            <b:ConditionExpression>
              <b:AttributeName>name</b:AttributeName>
              <b:Operator>Equal</b:Operator>
              <b:Values xmlns:d="http://schemas.microsoft.com/2003/10/Serialization/Arrays">
                <d:anyType i:type="s:string" xmlns:s="http://www.w3.org/2001/XMLSchema">Integration Specialists</d:anyType>
              </b:Values>
            </b:ConditionExpression>
          </b:Conditions>
          <b:FilterOperator>And</b:FilterOperator>
          <b:Filters>
            <b:FilterExpression>
              <b:Conditions>
                <b:ConditionExpression>
                  <b:AttributeName>name</b:AttributeName>
                  <b:Operator>NotEqual</b:Operator>
                  <b:Values xmlns:d="http://schemas.microsoft.com/2003/10/Serialization/Arrays">
                    <d:anyType i:type="s:string" xmlns:s="http://www.w3.org/2001/XMLSchema">Bob</d:anyType>
                  </b:Values>
                </b:ConditionExpression>
              </b:Conditions>
              <b:FilterOperator>And</b:FilterOperator>
              <b:Filters />
            </b:FilterExpression>
          </b:Filters>
        </b:FilterExpression>)

      expect(subject.to_xml(namespace: 'b')).to match_xml fragment
    end
  end

  describe 'Criteria' do
    subject do
      criteria = DynamicsCRM::XML::Criteria.new
      criteria.filter_operator = 'Or'

      filter1 = DynamicsCRM::XML::FilterExpression.new('And')
      filter1.add_condition('name', 'Equal', 'Integration Specialists')
      filter1.add_condition('name', 'NotEqual', 'Bob')

      filter2 = DynamicsCRM::XML::FilterExpression.new('And')
      filter2.add_condition('name', 'Equal', 'Thematics Development Inc.')
      filter2.add_condition('name', 'NotEqual', 'Bob')

      criteria.add_filter(filter1)
      criteria.add_filter(filter2)

      criteria
    end

    it 'generates Criteria with Or Filters' do
      expect(subject.to_xml(namespace: 'b')).to match_xml criteria_with_or_filters
    end

    def criteria_with_or_filters
      %(<b:Criteria>
          <b:Conditions />
          <b:FilterOperator>Or</b:FilterOperator>
          <b:Filters>
            <b:FilterExpression>
              <b:Conditions>
                <b:ConditionExpression>
                  <b:AttributeName>name</b:AttributeName>
                  <b:Operator>Equal</b:Operator>
                  <b:Values xmlns:d="http://schemas.microsoft.com/2003/10/Serialization/Arrays">
                    <d:anyType i:type="s:string" xmlns:s="http://www.w3.org/2001/XMLSchema">Integration Specialists</d:anyType>
                  </b:Values>
                </b:ConditionExpression>
                <b:ConditionExpression>
                  <b:AttributeName>name</b:AttributeName>
                  <b:Operator>NotEqual</b:Operator>
                  <b:Values xmlns:d="http://schemas.microsoft.com/2003/10/Serialization/Arrays">
                    <d:anyType i:type="s:string" xmlns:s="http://www.w3.org/2001/XMLSchema">Bob</d:anyType>
                  </b:Values>
                </b:ConditionExpression>
              </b:Conditions>
              <b:FilterOperator>And</b:FilterOperator>
              <b:Filters />
            </b:FilterExpression>
            <b:FilterExpression>
              <b:Conditions>
                <b:ConditionExpression>
                  <b:AttributeName>name</b:AttributeName>
                  <b:Operator>Equal</b:Operator>
                  <b:Values xmlns:d="http://schemas.microsoft.com/2003/10/Serialization/Arrays">
                    <d:anyType i:type="s:string" xmlns:s="http://www.w3.org/2001/XMLSchema">Thematics Development Inc.</d:anyType>
                  </b:Values>
                </b:ConditionExpression>
                <b:ConditionExpression>
                  <b:AttributeName>name</b:AttributeName>
                  <b:Operator>NotEqual</b:Operator>
                  <b:Values xmlns:d="http://schemas.microsoft.com/2003/10/Serialization/Arrays">
                    <d:anyType i:type="s:string" xmlns:s="http://www.w3.org/2001/XMLSchema">Bob</d:anyType>
                  </b:Values>
                </b:ConditionExpression>
              </b:Conditions>
              <b:FilterOperator>And</b:FilterOperator>
              <b:Filters />
            </b:FilterExpression>
          </b:Filters>
        </b:Criteria>)
    end
  end
end
