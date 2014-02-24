module Mscrm
  module Soap
    module Metadata

      class EntityMetadata

        attr_reader :document
        def initialize(entity_xml)
          @document = entity_xml
        end

        # Allows access to attributes in underlying XML document.
        def method_missing(method, *args, &block)

          value = nil
          camel_name = method.to_s

          element = @document.get_elements("d:#{camel_name}").first
          if element.children.size == 1
            value = element.text
          else
            value = element
          end

          return value
        end

        def respond_to_missing?(method_name, include_private = false)
          camel_name = method_name.to_s.classify
          @document.get_elements("d:#{camel_case}").any? || super
        end
      end

    end
  end
end