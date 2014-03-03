module DynamicsCRM
  module Metadata

    # RetrieveEntity returns a single EntityMetadata element.
    class RetrieveEntityResponse < DynamicsCRM::Response::ExecuteResult
      attr_reader :entity, :attributes

      def initialize(xml)
        super

        # Single KeyValuePair containing 1 value type of EntityMetadata
        @entity = EntityMetadata.new(self["EntityMetadata"])
      end

    end
  end
end