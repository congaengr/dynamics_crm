module Mscrm
  module Soap
    module Metadata

      class RetrieveEntityResponse < Mscrm::Soap::Model::ExecuteResult
        attr_reader :entity

        def initialize(xml)
          super

          # Single KeyValuePair containing 1 value type of EntityMetadata
          @entity = EntityMetadata.new(self.delete("EntityMetadata"))
        end

      end
    end
  end
end