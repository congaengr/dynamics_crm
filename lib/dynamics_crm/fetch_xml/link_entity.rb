module DynamicsCRM
  module FetchXml
    class LinkEntity < FetchXml::Entity
      attr_accessor :from, :to, :alias, :conditions

      def initialize(logical_name, options={})
          super
          @from = options[:from]|| "#{logical_name}id"
          @to = options[:to] || "#{logical_name}id"
          @alias = options[:alias] || logical_name
          @conditions = []
      end

      def add_condition(attribute, operator, value)
        @conditions << {
          attribute: attribute,
          operator: operator,
          value: value
        }
        self
      end

      def has_conditions?
        @conditions.any?
      end
    end
  end
end