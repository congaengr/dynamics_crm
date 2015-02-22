module DynamicsCRM
  module Metadata

    class AttributeQueryExpression
      attr_accessor :criteria, :properties

      def initialize(criteria, properties)
        @criteria = criteria
        @properties = properties
      end

      def to_xml(options={})
        namespace = options[:namespace] ? options[:namespace] : 'b'

        xml = %Q{<#{namespace}:AttributeQuery>}
        xml << @criteria.to_xml({namespace: namespace}) if @criteria
        xml << @properties.to_xml({namespace: namespace}) if @properties
        xml << %Q{</#{namespace}:AttributeQuery>}

        return xml
      end
    end

  end
end
