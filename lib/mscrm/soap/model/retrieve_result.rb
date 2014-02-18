module Mscrm
  module Soap
    module Model
      class RetrieveResult < Result

        protected

        # Invoked by Result constructor
        def parse_result_response(result)
          h = {}
          h["LogicalName"] = h["type"] = result.elements["b:LogicalName"].text
          h["Id"] = h["id"] = result.elements["b:Id"].text

          attributes = MessageParser.parse_key_value_pairs(result.elements["b:Attributes"])
          h.merge(attributes)
        end

      end

    end
  end
end
