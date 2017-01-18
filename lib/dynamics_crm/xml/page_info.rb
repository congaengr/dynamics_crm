module DynamicsCRM
  module XML
    class PageInfo
      attr_accessor :count, :page_number, :paging_cookie, :return_total_record_count

      def initialize(count: 20, page_number: 1, paging_cookie: nil, return_total_record_count: false)
        @count = count
        @page_number = page_number
        @paging_cookie = paging_cookie
        @return_total_record_count = return_total_record_count
      end

      # Using Entity vs entity causes the error: Value cannot be null.
      def to_xml
        cookie = if paging_cookie.nil?
          '<b:PagingCookie i:nil="true" />'
        else
          %(<b:PagingCookie>#{CGI.escapeHTML(paging_cookie)}</b:PagingCookie>)
        end

        %(
        <b:PageInfo>
          <b:Count>#{count}</b:Count>
          <b:PageNumber>#{page_number}</b:PageNumber>
          #{cookie}
          <b:ReturnTotalRecordCount>#{return_total_record_count}</b:ReturnTotalRecordCount>
        </b:PageInfo>
        )
      end

      def to_hash
        {
          :count => count,
          :page_number => page_number,
          :paging_cookie => paging_cookie,
          :return_total_record_count => return_total_record_count
        }
      end
    end
    # PageInfo
  end
end
