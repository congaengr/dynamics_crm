module DynamicsCRM
  module Model

    class PageInfo

      attr_accessor :count, :page_number, :paging_cookie, :return_total_record_count
      def initialize
        @count = 20
        @page_number = 1
        @paging_cookie = nil
        @return_total_record_count = false
      end

      # Using Entity vs entity causes the error: Value cannot be null.
      def to_xml
        %Q{
        <b:PageInfo>
          <b:Count>#{count}</b:Count>
          <b:PageNumber>#{page_number}</b:PageNumber>
          <b:PagingCookie i:nil="true" />
          <b:ReturnTotalRecordCount>false</b:ReturnTotalRecordCount>
        </b:PageInfo>
        }
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