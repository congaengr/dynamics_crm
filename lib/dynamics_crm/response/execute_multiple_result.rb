module DynamicsCRM
  module Response
    class ExecuteMultipleResult < Result

      protected

      # Returns base element of the response document to parse.
      def response_element
        class_name = 'ExecuteResult' if self.is_a?(ExecuteMultipleResult)
      end

      # Invoked by Result constructor
      def parse_result_response(result)
        h = {}
        result.elements["b:Results"].each_element do |key_value_pair|
          if key_value_pair.elements["c:key"].text == "Responses"
            value_element = key_value_pair.elements["c:value"]
            h[:entities] = []
            value_element.each_element do |response_item|
              itemResults = response_item.elements["d:Response"].elements["b:Results"]
              if !itemResults.nil?
                h[:entities] << XML::MessageParser.parse_key_value_pairs(itemResults)
              end
            end
            break
          end
        end

        h
      end

    end

  end
end
