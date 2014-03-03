module DynamicsCRM
  module Metadata
    # Retrieve Attribute returns a single AttributeMetadata.
    class RetrieveAttributeResponse < DynamicsCRM::Response::ExecuteResult
      attr_reader :attribute

      def initialize(xml)
        super

        # Single KeyValuePair containing 1 value type of AttributeMetadata
        @attribute = AttributeMetadata.new(self.delete("AttributeMetadata"))
      end

    end
  end
end