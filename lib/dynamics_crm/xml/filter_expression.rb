module DynamicsCRM
  module XML
    # Represents FilterExpression XML fragment.
    class FilterExpression
      attr_accessor :conditions, :filters, :filter_operator

      def initialize(operator = 'And')
        @filter_operator = operator
        @conditions = []
        @filters = []
      end

      def add_condition(field, operator, value=nil)
        conditions << ConditionExpression.new(field, operator, value)
      end

      def add_filter(filter)
        filters << filter
      end

      def to_xml(options = {})
        ns = options[:namespace] ? options[:namespace] : 'b'

        query_xml = %(
          <#{ns}:FilterExpression>
            #{conditions_xml(options)}
            <#{ns}:FilterOperator>#{@filter_operator}</#{ns}:FilterOperator>
            #{filters_xml(options)}
          </#{ns}:FilterExpression>
        )

        query_xml
      end

      protected

      def conditions_xml(options)
        ns = options[:namespace] ? options[:namespace] : 'b'

        if conditions.empty?
          "<#{ns}:Conditions />"
        else
          xml = conditions.map { |c| c.to_xml(options) }.join('')
          %(<#{ns}:Conditions>
              #{xml}
            </#{ns}:Conditions>)
        end
      end

      def filters_xml(options)
        ns = options[:namespace] ? options[:namespace] : 'b'

        if filters.empty?
          "<#{ns}:Filters />"
        else
          sub_filters = filters.map { |f| f.to_xml(options) }.join('')
          %(<#{ns}:Filters>
              #{sub_filters}
            </#{ns}:Filters>)
        end
      end
    end
    # FilterExpression
  end
end
