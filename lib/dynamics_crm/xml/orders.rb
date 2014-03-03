module DynamicsCRM
  module XML
    # Represents Orders XML element.
    class Orders

      attr_accessor :attribute_name, :order_type

      def initialize
        @order_type = 0
      end

      # Using Entity vs entity causes the error: Value cannot be null.
      # <Order> can be repeated multiple times
      # orderType: 0 (Ascending) or 1 (Descending)
      def to_xml
        %Q{
		<a:Orders>
		    <a:Order>
		        <a:attributeName>#{attribute_name}</a:attributeName>
		        <a:orderType>#{order_type}</a:orderType>
		    </a:Order>
		</a:Orders>
        }
      end

      def to_hash
        {
          :attribute_name => attribute_name,
          :order_type => order_type
        }
      end

    end
    # Orders
  end
end