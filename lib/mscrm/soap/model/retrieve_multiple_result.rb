module Mscrm
  module Soap
    module Model
      class RetrieveMultipleResult < Result

        protected

        # Invoked by Result constructor
        def parse_result_response(result)

          h = {}
          result.elements.each do |el|
            next if el.name == "Entities"
            value = el.text
            if value == "true" || value == "false"
              value = (value == "true")
            elsif value =~ /^[-?]\d+$/
              value = value.to_i
            elsif value =~ /^[-?]\d+\.\d+$/
              value = value.to_f
            end
            h[el.name] = value
          end

          h[:entities] = []
          result.elements["b:Entities"].elements.each do |entity_xml|
            h[:entities] << Entity.from_xml(entity_xml)
          end

          h
        end

      end

    end
  end
end
