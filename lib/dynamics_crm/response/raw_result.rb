module DynamicsCRM
  module Response

    class RawResult

      attr_reader :result_response

      def initialize(xml)
        @result_response = xml
      end
	  end
  end
end