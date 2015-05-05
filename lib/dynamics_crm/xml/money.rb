module DynamicsCRM
  module XML
    class Money

      attr_accessor :value

      def initialize(value, precision=2)
        @value = "%.#{precision}f" % value
      end

      def to_xml(options={})
        @value
      end
    end
  end
end
