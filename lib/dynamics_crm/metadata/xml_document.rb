module DynamicsCRM
  module Metadata

    class XmlDocument

      attr_reader :document
      def initialize(document)
        @document = document
      end

      # Allows access to attributes in underlying XML document.
      def method_missing(method, *args, &block)
        value = nil
        return value if @document.nil?

        camel_name = method.to_s
        element = @document.get_elements("./[local-name() = '#{camel_name}']").first

        if element && element.children.size == 1 && element.children.first.is_a?(REXML::Text)
          value = element.text
        elsif element
          value = XmlDocument.new(element)
        else
          # This returns if no XML element was found to avoid nil errors.
          value = OpenStruct.new
        end

        # Return wrapper to support method_method missing.
        return value
      end

      def respond_to_missing?(method_name, include_private = false)
        camel_name = method_name.to_s
        @document.get_elements("d:#{camel_name}").any? || super
      end
    end

  end
end