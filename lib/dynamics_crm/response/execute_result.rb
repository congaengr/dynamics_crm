module DynamicsCRM
  module Response
    # Base response class for all Execute requests.
    # Pulls out the ResponseName and parses the Results element of key/value pairs.
    class ExecuteResult < Result

      protected

      # Returns base element of the response document to parse.
      def response_element
        class_name = 'ExecuteResult' if self.is_a?(ExecuteResult)
      end

      # Invoked by Result constructor
      def parse_result_response(result)
        h = {}
        h["ResponseName"] = result.elements["b:ResponseName"].text

        attributes = XML::MessageParser.parse_key_value_pairs(result.elements["b:Results"])
        h.merge(attributes)
      end

    end

  end
end
