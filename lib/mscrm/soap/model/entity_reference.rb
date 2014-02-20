module Mscrm
  module Soap
    module Model

      class EntityReference

        attr_accessor :id, :logical_name, :name, :namespace

        def initialize(logical_name, id)
          @logical_name = logical_name
          @id = id || "00000000-0000-0000-0000-000000000000"
        end

        def to_xml(namespace = nil)
          namespace = namespace ? "#{namespace}:" : ''

          %Q{
          <#{namespace}entityReference>
            <#{namespace}LogicalName>#{@logical_name}</#{namespace}LogicalName>
            <#{namespace}Id>#{@id}</#{namespace}Id>
            <#{namespace}Name #{@name ? '' : 'nil="true"'}>#{@name}</#{namespace}Name>
          </#{namespace}entityReference>
          }
        end

        def to_hash
          {
            :logical_name => @logical_name,
            :id => @id,
            :name => @name,
          }
        end

        def self.from_xml(xml_document)
          entity_ref = EntityReference.new('unknown', nil)

          if xml_document
            xml_document.elements.each do |node|

              attr_name = StringUtil.underscore(node.name).to_sym
              if entity_ref.respond_to?(attr_name)
                entity_ref.send("#{attr_name}=", node.text ? node.text.strip : nil)
              end
            end
          end

          return entity_ref
        end

      end
    end
  end
end
