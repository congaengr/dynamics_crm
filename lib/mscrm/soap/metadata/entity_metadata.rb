module Mscrm
  module Soap
    module Metadata

      class EntityMetadata < XmlDocument
        attr_reader :attributes

        def initialize(document)
          super

          @attributes = []
          document.get_elements("//d:Attributes/d:AttributeMetadata").each do |attr_metadata|
            @attributes << AttributeMetadata.new(attr_metadata)
          end
        end

      end

    end
  end
end