module DynamicsCRM
  module Response
    # Retrieve Multiple returns a list of Entities.
    class RetrieveMultipleResult < Result

      protected

      # Invoked by Result constructor
      def parse_result_response(result)

        h = {}
        result.elements.each do |el|
          next if el.name == "Entities"

          # Convert text to actual data types.
          h[el.name] = ::DynamicsCRM::StringUtil.valueOf(el.text)
        end

        h[:entities] = []
        result.elements["b:Entities"].elements.each do |entity_xml|
          h[:entities] << XML::Entity.from_xml(entity_xml)
        end

        h
      end

    end
    # RetrieveMultipleResult
  end
end
