module DynamicsCRM
  module XML
    class Criteria < Array
      SUPPORTED_OPERATORS = %w(And Or)
      attr_accessor :filter_operator

      def initialize(tuples = [], filter_operator: nil)
        filter_operator ||= 'And'
        raise "Supported operators: #{SUPPORTED_OPERATORS.join(',')}" if !SUPPORTED_OPERATORS.include?(filter_operator)

        super(tuples)
        @filter_operator = filter_operator

        # Convert to ConditionExpression
        @expressions = self.map do |tuple|
          attr_name, operator, value, data_type = *tuple
          ConditionExpression.new(attr_name, operator, value, type: data_type)
        end

        @filters = []
      end

      def add_condition(attr_name, operator, value = nil, type: nil)
        @expressions << ConditionExpression.new(attr_name, operator, value, type: type)
      end

      def add_filter(filter)
        @filters << filter
      end

      # ConditionExpression can be repeated multiple times
      # Operator: can be lots of values such as: eq (Equals), neq (Not Equals), gt (Greater Than)
      #           get the values from a fetch xml query
      # Values -> Value can be repeated multiple times
      # FilterOperator: and OR or depending on the filter requirements
      # Filters: can contain FilterExpressions to support complex logical statements.
      def to_xml(options = {})
        ns = options[:namespace] ? options[:namespace] : 'a'

        %(<#{ns}:Criteria>
            #{conditions_xml(options)}
            <#{ns}:FilterOperator>#{@filter_operator}</#{ns}:FilterOperator>
            #{filters_xml(options)}
        </#{ns}:Criteria>)
      end

      def conditions_xml(options)
        ns = options[:namespace] ? options[:namespace] : 'a'

        if @expressions.empty?
          "<#{ns}:Conditions />"
        else
          xml_expression = @expressions.map do |conditional|
            conditional.to_xml(options)
          end.join('')

          %(<#{ns}:Conditions>
            #{xml_expression}
          </#{ns}:Conditions>)
        end
      end

      def filters_xml(options)
        ns = options[:namespace] ? options[:namespace] : 'a'
        if @filters.empty?
          "<#{ns}:Filters />"
        else
          fx = @filters.map { |f| f.to_xml(options) }.join('')
          %(<#{ns}:Filters>#{fx}</#{ns}:Filters>)
        end
      end
    end
    # Criteria
  end
end
