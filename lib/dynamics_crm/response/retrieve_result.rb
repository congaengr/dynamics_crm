module DynamicsCRM
  module Response
    class RetrieveResult < Result

      # Returns RetrieveResult response body as an Entity object.
      def entity
        @entity ||= XML::Entity.from_xml(@result_response)
      end

      protected

      # Invoked by Result constructor
      def parse_result_response(result)
        h = {}
        h["LogicalName"] = h["type"] = result.elements["b:LogicalName"].text
        h["Id"] = h["id"] = result.elements["b:Id"].text

        attributes = XML::MessageParser.parse_key_value_pairs(result.elements["b:Attributes"])
        h.merge(attributes)
      end

    end
    # RetrieveResult
  end
end
