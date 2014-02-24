module Mscrm
  module Soap
    module Metadata

      class RetrieveAttributeResponse < Mscrm::Soap::Model::ExecuteResult
        attr_reader :attributes

        def initialize(xml)
          super

          # Single KeyValuePair containing 1 value type of EntityMetadata
          @attributes = AttributeMetadata.new(self.delete("AttributeMetadata"))
        end

      end
    end
  end
end