require 'builder'

# <fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
#   <entity name="opportunityproduct">
#     <attribute name="productid" />
#     <attribute name="productdescription" />
#     <attribute name="priceperunit" />
#     <attribute name="quantity" />
#     <attribute name="extendedamount" />
#     <attribute name="opportunityproductid" />
#     <order attribute="productid" descending="false" />
#     <link-entity name="product" from="productid" to="productid" alias="product">
#       <attribute name="name" />
#       <attribute name="producttypecode" />
#       <attribute name="price" />
#       <attribute name="standardcost" />
#       <attribute name="currentcost" />
#     </link-entity>
#     <link-entity name="opportunity" from="opportunityid" to="opportunityid" alias="opportunity">
#       <filter type="and">
#           <condition attribute="opportunityid" operator="eq" value="02dd7344-d04a-e411-a9d3-9cb654950300" />
#       </filter>
#     </link-entity>
#   </entity>
# </fetch>
module DynamicsCRM
  module FetchXml

    class Builder
      attr_accessor :version, :output_format, :mapping, :distinct

      def initialize(options={})
        @entities = []
        @link_entities = []

        @version = options[:version] || '1.0'
        @output_format = options[:output_format] || 'xml-platform'
        @mapping = options[:mapping] || 'logical'
        @distinct = options[:distinct] || false
      end

      def entity(logical_name)
        @entities << Entity.new(logical_name)
        @entities.last
      end

      def to_xml
        @builder = ::Builder::XmlMarkup.new(:indent=>2)
        # <fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
        builder.fetch(version: @version, :"output-format" => @output_format, mapping: @mapping, distinct: @distinct) {
          @entities.each do |e|
            # <entity name="opportunityproduct">
            builder.entity(name: e.logical_name) {
              e.attributes.each do |field|
                # <attribute name="productid" />
                builder.attribute(name: field)
              end

              if e.order_field
                builder.order(attribute: e.order_field, descending: e.order_desc)
              end

              add_link_entities(e)

              add_filter_conditions(e) if e.has_conditions?

            # </entity>
            }
          end
        }
        builder.target!
      end

      protected

      attr_accessor :builder

      def add_link_entities(e)
        e.link_entities.each do |le|
          # <link-entity name="product" from="productid" to="productid" alias="product" link-type="outer">
          # NOTE: Use outer join in case related elements do not exist.
          builder.tag!('link-entity', name: le.logical_name, from: le.from, to: le.to, :alias => le.alias, :"link-type" => le.link_type) {
            le.attributes.each do |field|
              # <attribute name="name" />
              builder.attribute(name: field)
            end
            add_filter_conditions(le) if le.has_conditions?

            # Support nested link-entity elements. Recursive.
            add_link_entities(le)
          }
          # </link-entity>
        end
      end

      def add_filter_conditions(e)
        builder.filter(type: 'and') {
          e.conditions.each do |c|
            if 'in' == c[:operator]
              builder.condition(attribute: c[:attribute], operator: c[:operator]) do 
                c[:value].each {|v| builder.value v }
              end
            else
              builder.condition(attribute: c[:attribute], operator: c[:operator], value: c[:value])
            end
          end
        }
      end

    end
  end
end
