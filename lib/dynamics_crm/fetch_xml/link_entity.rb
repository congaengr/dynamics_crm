module DynamicsCRM
  module FetchXml
    class LinkEntity < FetchXml::Entity
      attr_accessor :from, :to, :alias, :link_type

      def initialize(logical_name, options={})
          super
          @from = options[:from]|| "#{logical_name}id"
          @to = options[:to] || "#{logical_name}id"
          @alias = options[:alias] || logical_name
          @link_type = options[:link_type] || "inner"
      end

    end
  end
end