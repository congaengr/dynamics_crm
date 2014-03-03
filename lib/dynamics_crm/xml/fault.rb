module DynamicsCRM
  module XML

    # Represents a SOAP Fault
    # Resposible for parsing each element
    class Fault < RuntimeError

      attr_reader :code, :subcode, :reason, :detail

      def initialize(fault_xml)
        if fault_xml.is_a?(Array)
          fault_xml = fault_xml.first
        end
        # REXL::Element
        @code = fault_xml.get_text("//[local-name() = 'Code']/[local-name() = 'Value']")
        @subcode = fault_xml.get_text("//[local-name() = 'Code']/[local-name() = 'Subcode']/[local-name() = 'Value']")
        @reason = fault_xml.get_text("//[local-name() = 'Reason']/[local-name() = 'Text']")

        @detail = {}
        detail_fragment = fault_xml.get_elements("//[local-name() = 'Detail']").first
        if detail_fragment
          fault_type = detail_fragment.elements.first
          @detail[:type] = fault_type.name
          detail_fragment.elements.first.each_element do |node|

            @detail[node.name.to_sym] = node.text
          end
        end
      end

      def message
        if @detail.empty?
          "%s[%s] %s" % [@code, @subcode, @reason]
        else
          "%s[%s] %s (Detail => %s)" % [@code, @subcode, @reason, @detail]
        end
      end

    end
    # Fault
  end
end
