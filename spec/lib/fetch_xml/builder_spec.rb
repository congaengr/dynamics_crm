require 'spec_helper'

describe DynamicsCRM::FetchXml::Builder do

  describe 'xml' do
    let(:opportunity_product_fields) {
      ['productid', 'productdescription', 'priceperunit', 'quantity', 'extendedamount', 'opportunityproductid']
    }
    let(:product_fields) {
      ['name', 'producttypecode', 'price', 'standardcost', 'currentcost']
    }

    context "entity" do
      it "builds a single entity" do
        subject.entity('opportunityproduct').add_attributes(opportunity_product_fields)
        expect(subject.to_xml).to eq %Q{<fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
  <entity name="opportunityproduct">
    <attribute name="productid"/>
    <attribute name="productdescription"/>
    <attribute name="priceperunit"/>
    <attribute name="quantity"/>
    <attribute name="extendedamount"/>
    <attribute name="opportunityproductid"/>
  </entity>
</fetch>
}
      end

      it "builds a single entity with order" do
        subject.entity('opportunityproduct').add_attributes(opportunity_product_fields).order('productid')
        expect(subject.to_xml).to eq %Q{<fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
  <entity name="opportunityproduct">
    <attribute name="productid"/>
    <attribute name="productdescription"/>
    <attribute name="priceperunit"/>
    <attribute name="quantity"/>
    <attribute name="extendedamount"/>
    <attribute name="opportunityproductid"/>
    <order attribute="productid" descending="false"/>
  </entity>
</fetch>
}
      end

      it "builds a single entity with condition" do
        entity = subject.entity('opportunity').add_attributes(['name', 'amount', 'ownerid'])
        entity.add_condition('opportunityid', 'eq', '02dd7344-d04a-e411-a9d3-9cb654950300')
        expect(subject.to_xml).to eq %Q{<fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
  <entity name="opportunity">
    <attribute name="name"/>
    <attribute name="amount"/>
    <attribute name="ownerid"/>
    <filter type="and">
      <condition attribute="opportunityid" operator="eq" value="02dd7344-d04a-e411-a9d3-9cb654950300"/>
    </filter>
  </entity>
</fetch>
}
      end

      it "builds a single entity with 'in' condition" do
        entity = subject.entity('opportunity').add_attributes(['name', 'amount', 'ownerid'])
        entity.add_condition('opportunityid', 'in', ['6055FD14-493B-E411-80BE-00155D2A4C29', '02dd7344-d04a-e411-a9d3-9cb654950300'])
        expect(subject.to_xml).to eq %Q{<fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
  <entity name="opportunity">
    <attribute name="name"/>
    <attribute name="amount"/>
    <attribute name="ownerid"/>
    <filter type="and">
      <condition attribute="opportunityid" operator="in">
        <value>6055FD14-493B-E411-80BE-00155D2A4C29</value>
        <value>02dd7344-d04a-e411-a9d3-9cb654950300</value>
      </condition>
    </filter>
  </entity>
</fetch>
}
      end
    end

    context "link_entity" do
      it "builds entity with link_entity" do
        entity = subject.entity('opportunityproduct').add_attributes(opportunity_product_fields).order('productid')
        entity.link_entity('product', to: 'productid', from: 'productid', :alias => 'prod', link_type: 'outer').add_attributes(product_fields)
        expect(subject.to_xml).to eq %Q{<fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
  <entity name="opportunityproduct">
    <attribute name="productid"/>
    <attribute name="productdescription"/>
    <attribute name="priceperunit"/>
    <attribute name="quantity"/>
    <attribute name="extendedamount"/>
    <attribute name="opportunityproductid"/>
    <order attribute="productid" descending="false"/>
    <link-entity name="product" from="productid" to="productid" alias="prod" link-type="outer">
      <attribute name="name"/>
      <attribute name="producttypecode"/>
      <attribute name="price"/>
      <attribute name="standardcost"/>
      <attribute name="currentcost"/>
    </link-entity>
  </entity>
</fetch>
}
      end
    end

    context "link_entity condition" do
      it "builds entity with two link_entity and condition" do
        entity = subject.entity('opportunityproduct').add_attributes(opportunity_product_fields).order('productid')
        entity.link_entity('product', to: 'productid', from: 'productid', :alias => 'prod').add_attributes(product_fields)
        entity.link_entity('opportunity', :alias => 'oppty').
          add_condition('opportunityid', 'eq', '02dd7344-d04a-e411-a9d3-9cb654950300')
        expect(subject.to_xml).to eq %Q{<fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
  <entity name="opportunityproduct">
    <attribute name="productid"/>
    <attribute name="productdescription"/>
    <attribute name="priceperunit"/>
    <attribute name="quantity"/>
    <attribute name="extendedamount"/>
    <attribute name="opportunityproductid"/>
    <order attribute="productid" descending="false"/>
    <link-entity name="product" from="productid" to="productid" alias="prod" link-type="inner">
      <attribute name="name"/>
      <attribute name="producttypecode"/>
      <attribute name="price"/>
      <attribute name="standardcost"/>
      <attribute name="currentcost"/>
    </link-entity>
    <link-entity name="opportunity" from="opportunityid" to="opportunityid" alias="oppty" link-type="inner">
      <filter type="and">
        <condition attribute="opportunityid" operator="eq" value="02dd7344-d04a-e411-a9d3-9cb654950300"/>
      </filter>
    </link-entity>
  </entity>
</fetch>
}
      end

      it "builds entity with link_entity and in condition" do
        entity = subject.entity('opportunityproduct').add_attributes(opportunity_product_fields).order('productid')
        entity.link_entity('opportunity', :alias => 'oppty').
          add_condition('opportunityid', 'in', ['6055FD14-493B-E411-80BE-00155D2A4C29', '02dd7344-d04a-e411-a9d3-9cb654950300'])
        expect(subject.to_xml).to eq %Q{<fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
  <entity name="opportunityproduct">
    <attribute name="productid"/>
    <attribute name="productdescription"/>
    <attribute name="priceperunit"/>
    <attribute name="quantity"/>
    <attribute name="extendedamount"/>
    <attribute name="opportunityproductid"/>
    <order attribute="productid" descending="false"/>
    <link-entity name="opportunity" from="opportunityid" to="opportunityid" alias="oppty" link-type="inner">
      <filter type="and">
        <condition attribute="opportunityid" operator="in">
          <value>6055FD14-493B-E411-80BE-00155D2A4C29</value>
          <value>02dd7344-d04a-e411-a9d3-9cb654950300</value>
        </condition>
      </filter>
    </link-entity>
  </entity>
</fetch>
}
      end
    end
  end

end
