module DynamicsCRM
  module Response

    class RawResult

      attr_reader :document
      attr_reader :result_response

	  def initialize(xml)
	    @document = REXML::Document.new(xml)

	    fault_xml = @document.get_elements("//[local-name() = 'Fault']")
	    raise XML::Fault.new(fault_xml) if fault_xml.any?

	    @result_response = xml
	  end
	end
  end
end