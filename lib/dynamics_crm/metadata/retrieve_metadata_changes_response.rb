module DynamicsCRM
  module Metadata

    class RetrieveMetadataChangesResponse < DynamicsCRM::Response::ExecuteResult
      attr_reader :entities

      def initialize(xml)
        super
        @entities = []

        self.delete("EntityMetadata").each do |em_xml|
          @entities << EntityMetadata.new(em_xml)
        end
      end
    end

  end
end
