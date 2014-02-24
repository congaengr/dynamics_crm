module Mscrm
  module Soap
    module Metadata

      class RetrieveAllEntitiesResponse < Mscrm::Soap::Model::ExecuteResult
        attr_reader :entities

        def initialize(xml)
          super

          @entities = []

          # Single KeyValuePair of EntityMetadata -> [EntityMetdata,...]
          self.delete("EntityMetadata").each do |em_xml|
            @entities << EntityMetadata.new(em_xml)
          end
        end

      end
    end
  end
end