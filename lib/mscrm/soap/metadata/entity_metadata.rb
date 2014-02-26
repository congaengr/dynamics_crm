module Mscrm
  module Soap
    module Metadata

      class EntityMetadata < XmlDocument
        attr_reader :attributes

        def initialize(document)
          super
        end

        def attributes
          return if @attributes.is_a?(Array)

          @attributes = document.get_elements("//d:Attributes/d:AttributeMetadata").collect do |attr_metadata|
            AttributeMetadata.new(attr_metadata)
          end

          return @attributes
        end

      end

    end
  end
end