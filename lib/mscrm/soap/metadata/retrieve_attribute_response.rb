module Mscrm
  module Soap
    module Metadata

      class RetrieveAttributeResponse < Mscrm::Soap::Model::ExecuteResult
        attr_reader :attribute

        def initialize(xml)
          super

          # Single KeyValuePair containing 1 value type of AttributeMetadata
          @attribute = AttributeMetadata.new(self.delete("AttributeMetadata"))
        end

      end
    end
  end
end