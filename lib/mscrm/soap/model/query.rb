module Mscrm
  module Soap
    module Model

      class Query

        attr_accessor :columns, :criteria, :entity_name

        def initialize(entity_name)
          @entity_name = entity_name
        end

        def to_xml(options={})
          namespace = options[:namespace] ? options[:namespace] : "b"

          column_set = Model::ColumnSet.new(columns)
          @criteria ||= Model::Criteria.new

          xml = %Q{
              #{column_set.to_xml(namespace: namespace, camel_case: true)}
              #{@criteria.to_xml(namespace: namespace)}
              <#{namespace}:Distinct>false</#{namespace}:Distinct>
              <#{namespace}:EntityName>#{entity_name}</#{namespace}:EntityName>
              <#{namespace}:LinkEntities />
              <#{namespace}:Orders />
            }

          if options[:exclude_root].nil?
            xml = %Q{<query i:type="b:QueryExpression" xmlns:b="http://schemas.microsoft.com/xrm/2011/Contracts" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
                #{xml}
            </query>}
          end
          return xml
        end

      end
      # ColumnSet
    end
  end
end
