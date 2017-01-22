module DynamicsCRM
  module XML
    # Represents QueryExpression XML fragment.
    class QueryExpression
      attr_accessor :columns, :criteria, :entity_name, :page_info

      def initialize(entity_name)
        @entity_name = entity_name
        @criteria = Criteria.new
      end

      def to_xml(options = {})
        namespace = options[:namespace] ? options[:namespace] : 'b'

        column_set = columns.is_a?(ColumnSet) ? columns : ColumnSet.new(columns)

        xml = %(
            #{column_set.to_xml(namespace: namespace, camel_case: true)}
            #{criteria.to_xml(namespace: namespace)}
            <#{namespace}:Distinct>false</#{namespace}:Distinct>
            <#{namespace}:EntityName>#{entity_name}</#{namespace}:EntityName>
            <#{namespace}:LinkEntities />
            <#{namespace}:Orders />
          )

        xml << page_info.to_xml if page_info

        if options[:exclude_root].nil?
          xml = %(<query i:type="b:QueryExpression" xmlns:b="http://schemas.microsoft.com/xrm/2011/Contracts" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
              #{xml}
          </query>)
        end

        xml
      end
    end
    # QueryExpression

    # Backward compatible class
    class Query < QueryExpression
    end
  end
end
