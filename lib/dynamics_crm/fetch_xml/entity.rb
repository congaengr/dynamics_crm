module DynamicsCRM
  module FetchXml
    class Entity
      attr_reader :logical_name, :attributes
      attr_reader :order_field, :order_desc
      attr_reader :link_entities

      def initialize(logical_name, options={})
        # options used by LinkEntity subclass
        @logical_name = logical_name
        @attributes = []
        @link_entities = []
      end

      def add_attributes(field_names=nil)
        @attributes = field_names
        self
      end

      # <order attribute="productid" descending="false" />
      def order(field_name, descending=false)
        @order_field = field_name
        @order_desc = descending
        self
      end

      def link_entity(logical_name, attributes={})
        @link_entities << LinkEntity.new(logical_name, attributes)
        @link_entities.last
      end

    end
  end
end