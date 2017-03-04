module DynamicsCRM
  module XML
    # Loosely based on https://msdn.microsoft.com/en-us/library/gg334419.aspx
    # Creates a ConditionExpression element to be used in retrieve calls.
    class ConditionExpression
      attr_accessor :attr_name, :operator, :value, :type

      def initialize(attr_name, operator, value = nil, type: nil)
        @attr_name = attr_name
        @operator = operator
        # value can be optional to support Null and NotNull operators
        @value = value
        @values = Array(value)
        @type = type
      end

      def value_type
        return type unless type.nil?

        type = @values.first.class.to_s.downcase
        if type == 'fixnum'
          type = 'int'
        elsif %w(trueclass falseclass).include?(type)
          type = 'boolean'
        end

        type
      end

      def to_xml(options = {})
        ns = options[:namespace] ? options[:namespace] : 'a'

        expression = %(<#{ns}:ConditionExpression>
            <#{ns}:AttributeName>#{attr_name}</#{ns}:AttributeName>
            <#{ns}:Operator>#{operator}</#{ns}:Operator>
            <#{ns}:Values xmlns:d="http://schemas.microsoft.com/2003/10/Serialization/Arrays">
          )
        @values.each do |v|
          expression << %(<d:anyType i:type="s:#{value_type}" xmlns:s="http://www.w3.org/2001/XMLSchema">#{v}</d:anyType>)
        end

        expression << %(
             </#{ns}:Values>
        </#{ns}:ConditionExpression>)

        expression
      end
    end
  end
end
