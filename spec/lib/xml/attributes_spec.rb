require 'spec_helper'

describe DynamicsCRM::XML::Attributes do

  describe 'initialization' do
    let(:attrs) {
      {
        "telephone1" => "123-213-1234",
        "modifiedon" => Time.now,
        "donotemail" => true,
        "id" => "1bfa3886-df7e-468c-8435-b5adfb0441ed",
        "reference" => {"Id" => "someid", "Name" => "entityname", "LogicalName" => "opportunity"},
        "expireson" => nil,
        "address1_latitude" => DynamicsCRM::Metadata::Double.new(5.22123)
      }
    }
    subject {
      DynamicsCRM::XML::Attributes.new(attrs)
    }

    context "attributes extends hash" do
      it { expect(subject).to eq(attrs) }
    end

    context "attributes uses method_missing for hash access" do
      it { expect(subject.telephone1).to eq(attrs["telephone1"])}
      it { expect(subject.modifiedon).to eq(attrs["modifiedon"])}
      it { expect(subject.donotemail).to eq(attrs["donotemail"])}
      it { expect(subject.id).to eq(attrs["id"])}
      it { expect(subject.reference).to eq(attrs["reference"])}
    end

    context "parse attributes according to their type" do
      it { expect(subject.to_xml).to include("<c:key>telephone1</c:key>") }
      it { expect(subject.to_xml).to include("<c:key>donotemail</c:key>") }
      it { expect(subject.to_xml).to include("<c:key>modifiedon</c:key>") }
      it { expect(subject.to_xml).to include('<c:value i:nil="true"></c:value>') }
      it do
        expect(subject.to_xml)
          .to include('<c:value i:type="s:double" xmlns:s="http://www.w3.org/2001/XMLSchema">5.22123</c:value>')
      end
    end

  end

end
