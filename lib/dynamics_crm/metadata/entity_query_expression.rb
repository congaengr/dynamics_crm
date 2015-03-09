module DynamicsCRM
  module Metadata

    class EntityQueryExpression

      attr_accessor :criteria, :properties, :attribute_query

      def initialize(options={})
        @criteria = options[:criteria]
        @properties = options[:properties]
        @attribute_query = options[:attribute_query]
      end

      def to_xml(options={})
        namespace = options[:namespace] ? options[:namespace] : "b"

        xml = ""
        xml << @criteria.to_xml({namespace: namespace}) if @criteria
        xml << @properties.to_xml({namespace: namespace}) if @properties
        xml << @attribute_query.to_xml({namespace: namespace}) if @attribute_query
        xml << "<#{namespace}:ExtensionData i:nil='true' />"
        xml << "<#{namespace}:LabelQuery  i:nil='true' />"
        xml << "<#{namespace}:RelationshipQuery i:nil='true' />"
        xml
      end
    end

  end
end
