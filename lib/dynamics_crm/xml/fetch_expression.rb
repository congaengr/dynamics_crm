module DynamicsCRM
  module XML
    class FetchExpression

      def initialize(fetch_xml)
        @fetch = fetch_xml
      end

      # Using Entity vs entity causes the error: Value cannot be null.
      # <Order> can be repeated multiple times
      # orderType: 0 (Ascending) or 1 (Descending)
      def to_xml(options={})
        %Q{
		    <a:Query>
		        #{CGI.escapeHTML(@fetch)}
		    </a:Query>
        }
      end

      def to_hash
        {:fetch_xml => @fetch}
      end

    end

  end
end