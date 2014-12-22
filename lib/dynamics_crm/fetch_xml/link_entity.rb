module DynamicsCRM
  module FetchXml
    class LinkEntity < FetchXml::Entity
      attr_accessor :from, :to, :alias

      def initialize(logical_name, options={})
          super
          @from = options[:from]|| "#{logical_name}id"
          @to = options[:to] || "#{logical_name}id"
          @alias = options[:alias] || logical_name
      end

    end
  end
end