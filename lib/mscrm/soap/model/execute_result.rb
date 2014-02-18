module Mscrm
  module Soap
    module Model
      class ExecuteResult < Result

        protected

        # Invoked by Result constructor
        def parse_result_response(result)
          h = {}
          h["ResponseName"] = result.elements["b:ResponseName"].text

          attributes = MessageParser.parse_key_value_pairs(result.elements["b:Results"])
          h.merge(attributes)
        end

      end

    end
  end
end
