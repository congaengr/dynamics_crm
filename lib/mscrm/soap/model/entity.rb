module Mscrm
  module Soap
    module Model

      class Entity

        attr_accessor :attributes, :entity_state, :formatted_values, :id, :logical_name, :related_entities

        def initialize(logical_name)
          @logical_name = logical_name
          @id = "00000000-0000-0000-0000-000000000000"
        end

        # Using Entity vs entity causes the error: Value cannot be null.
        def to_xml
          %Q{
          <entity xmlns:a="http://schemas.microsoft.com/xrm/2011/Contracts">
            #{@attributes}
            <a:EntityState i:nil="true" />
            <a:FormattedValues xmlns:b="http://schemas.datacontract.org/2004/07/System.Collections.Generic" />
            <a:Id>#{@id}</a:Id>
            <a:LogicalName>#{@logical_name}</a:LogicalName>
            <a:RelatedEntities xmlns:b="http://schemas.datacontract.org/2004/07/System.Collections.Generic" />
          </entity>
          }
        end

        def to_s
          self.to_xml
        end
      end
    end
  end
end
