module DynamicsCRM
  module XML
    class Money

      attr_accessor :value

      def initialize(value, precision=2)
        @value = "%.#{precision}f" % value
      end

      def to_xml(options={})
        "<a:Value>#{@value}</a:Value>"
      end
    end
  end
end
