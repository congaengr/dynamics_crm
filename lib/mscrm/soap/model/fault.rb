module Mscrm
  module Soap
    module Model

      # Represents a SOAP Fault
      # Resposible for parsing each element
      class Fault < RuntimeError

        attr_reader :code, :subcode, :reason

        def initialize(fault_xml)
          if fault_xml.is_a?(Array)
            fault_xml = fault_xml.first
          end
          # REXL::Element
          @code = fault_xml.get_text("//[local-name() = 'Code']/[local-name() = 'Value']")
          @subcode = fault_xml.get_text("//[local-name() = 'Code']/[local-name() = 'Subcode']/[local-name() = 'Value']")
          @reason = fault_xml.get_text("//[local-name() = 'Reason']/[local-name() = 'Text']")
        end

        def message
          "%s[%s] %s" % [@code, @subcode, @reason]
        end
      end

    end
  end
end
