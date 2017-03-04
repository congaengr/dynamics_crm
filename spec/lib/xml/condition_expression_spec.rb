require 'spec_helper'

describe DynamicsCRM::XML::ConditionExpression do
  it 'generates base ConditionExpresion' do
    subject = DynamicsCRM::XML::ConditionExpression.new('name', 'Equal', 'GitHub')

    fragment = %(
      <b:ConditionExpression>
        <b:AttributeName>name</b:AttributeName>
        <b:Operator>Equal</b:Operator>
        <b:Values xmlns:d="http://schemas.microsoft.com/2003/10/Serialization/Arrays">
          <d:anyType i:type="s:string" xmlns:s="http://www.w3.org/2001/XMLSchema">GitHub</d:anyType>
        </b:Values>
      </b:ConditionExpression>)

    expect(subject.to_xml(namespace: 'b')).to match_xml fragment
  end

  it 'supports boolean values' do
    subject = DynamicsCRM::XML::ConditionExpression.new('isactive', 'Equal', true)

    fragment = %(
      <b:ConditionExpression>
        <b:AttributeName>isactive</b:AttributeName>
        <b:Operator>Equal</b:Operator>
        <b:Values xmlns:d="http://schemas.microsoft.com/2003/10/Serialization/Arrays">
          <d:anyType i:type="s:boolean" xmlns:s="http://www.w3.org/2001/XMLSchema">true</d:anyType>
        </b:Values>
      </b:ConditionExpression>)

    expect(subject.to_xml(namespace: 'b')).to match_xml fragment
  end

  it 'supports Array values' do
    subject = DynamicsCRM::XML::ConditionExpression.new('salesstage', 'In', [0, 1, 2])

    fragment = %(
      <b:ConditionExpression>
        <b:AttributeName>salesstage</b:AttributeName>
        <b:Operator>In</b:Operator>
        <b:Values xmlns:d="http://schemas.microsoft.com/2003/10/Serialization/Arrays">
          <d:anyType i:type="s:int" xmlns:s="http://www.w3.org/2001/XMLSchema">0</d:anyType>
          <d:anyType i:type="s:int" xmlns:s="http://www.w3.org/2001/XMLSchema">1</d:anyType>
          <d:anyType i:type="s:int" xmlns:s="http://www.w3.org/2001/XMLSchema">2</d:anyType>
        </b:Values>
      </b:ConditionExpression>)

    expect(subject.to_xml(namespace: 'b')).to match_xml fragment
  end

  it 'supports Null operator without value' do
    subject = DynamicsCRM::XML::ConditionExpression.new('telephone1', 'Null')

    fragment = %(
      <b:ConditionExpression>
        <b:AttributeName>telephone1</b:AttributeName>
        <b:Operator>Null</b:Operator>
        <b:Values xmlns:d="http://schemas.microsoft.com/2003/10/Serialization/Arrays">
        </b:Values>
      </b:ConditionExpression>)

    expect(subject.to_xml(namespace: 'b')).to match_xml fragment
  end
end
