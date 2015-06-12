module DynamicsCRM
  module Metadata

    class FilterExpression
      attr_accessor :operator, :conditions

      def initialize(operator, conditions=[])
        @operator   = operator || 'And'
        @conditions = conditions
      end

      def add_condition(condition)
        @conditions << condition
      end

      def get_type(value)
          type = value.class.to_s.downcase
          type = "int" if type == "fixnum"
          type = "boolean" if ["trueclass", "falseclass"].include?(type)
          type
      end

      def to_xml(options={})
        ns = options[:namespace] ? options[:namespace] : "a"

        expressions = ""
        @conditions.each do |condition|
          attr_name, op, value = condition

          expressions << %Q{
            <#{ns}:MetadataConditionExpression>
              <#{ns}:PropertyName>#{attr_name}</#{ns}:PropertyName>
              <#{ns}:ConditionOperator>#{op}</#{ns}:ConditionOperator>
              <#{ns}:Value i:type='e:#{get_type(value)}' xmlns:e='http://www.w3.org/2001/XMLSchema'>#{value}</#{ns}:Value>
           </#{ns}:MetadataConditionExpression>}
        end

        %Q{<#{ns}:Criteria>
            <#{ns}:Conditions>
              #{expressions}
            </#{ns}:Conditions>
            <#{ns}:FilterOperator>#{@operator}</#{ns}:FilterOperator>
        </#{ns}:Criteria>}
      end
    end
  end
end
