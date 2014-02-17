module Mscrm
  module Soap
    module Model

      class ColumnSet < Array

        def initialize(column_names)
          super
        end

        def to_s
          self.to_xml
        end

        def to_xml

          if self.any?
            column_set = '<b:Columns xmlns:c="http://schemas.microsoft.com/2003/10/Serialization/Arrays">'
            self.each do |name|
              column_set << "\n<c:string>#{name}</c:string>"
            end
            column_set << "\n</b:Columns>"
          end

          %Q{<columnSet xmlns:b="http://schemas.microsoft.com/xrm/2011/Contracts" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
              <b:AllColumns>#{self.empty?}</b:AllColumns>
              #{column_set}
            </columnSet>}
        end
      end
      # ColumnSet
    end
  end
end
