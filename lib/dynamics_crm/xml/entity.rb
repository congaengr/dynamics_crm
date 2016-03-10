module DynamicsCRM
  module XML

    class Entity

      attr_accessor :attributes, :entity_state, :formatted_values, :id, :logical_name, :related_entities

      def initialize(logical_name, id=nil)
        @logical_name = logical_name
        @id = id || "00000000-0000-0000-0000-000000000000"
      end

      # Using Entity vs entity causes the error: Value cannot be null.
      def to_xml(options={})

        inner_xml = %Q{
          #{@attributes.is_a?(XML::Attributes) ? @attributes.to_xml : @attributes}
          <a:EntityState i:nil="true" />
          <a:FormattedValues xmlns:b="http://schemas.datacontract.org/2004/07/System.Collections.Generic" />
          <a:Id>#{@id}</a:Id>
          <a:LogicalName>#{@logical_name}</a:LogicalName>
          <a:RelatedEntities xmlns:b="http://schemas.datacontract.org/2004/07/System.Collections.Generic" />
        }

        return inner_xml if options[:exclude_root]

        if options[:in_array]
          %Q{
          <a:Entity>
            #{inner_xml}
          </a:Entity>
          }
        else
          %Q{
          <entity xmlns:a="http://schemas.microsoft.com/xrm/2011/Contracts">
            #{inner_xml}
          </entity>
          }
        end
      end

      def to_hash
        {
          :attributes => @attributes.to_hash,
          :entity_state => entity_state,
          :formatted_values => (@formatted_values ? @formatted_values.to_hash : nil),
          :id => @id,
          :logical_name => @logical_name,
          :related_entities => related_entities
        }
      end

      def self.from_xml(xml_document)
        entity = Entity.new('')

        if xml_document
          xml_document.elements.each do |node|

            attr_name = DynamicsCRM::StringUtil.underscore(node.name).to_sym
            if entity.respond_to?(attr_name)
              if node.name == "Attributes"
                entity.attributes = XML::Attributes.from_xml(node)
              elsif node.name == "FormattedValues"
                entity.formatted_values = XML::FormattedValues.from_xml(node)
                # Reset to nil if no values were found.
                entity.formatted_values = nil if entity.formatted_values.empty?
              else
                entity.send("#{attr_name}=", node.text ? node.text.strip : nil)
              end
            end
          end
        end

        return entity
      end

    end
    # Entity
  end
end
