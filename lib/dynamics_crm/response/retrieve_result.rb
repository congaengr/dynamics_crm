module DynamicsCRM
  module Response
    class RetrieveResult < Result

      # Returns RetrieveResult response body as an Entity object.
      def entity
        @entity ||= XML::Entity.from_xml(@result_response)
      end

      protected

      # Invoked by Result constructor
      def parse_result_response(result, prefix)
        h = {}
        h["LogicalName"] = h["type"] = result.elements["#{prefix}:LogicalName"].text
        h["Id"] = h["id"] = result.elements["#{prefix}:Id"].text

        attributes = XML::MessageParser.parse_key_value_pairs(result.elements["#{prefix}:Attributes"])
        h.merge(attributes)
      end

    end
    # RetrieveResult
  end
end
