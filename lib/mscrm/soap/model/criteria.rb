module Mscrm
  module Soap
    module Model

      class Criteria < Array

        attr_accessor :filter_operator
        def initialize(tuples)
          super
          @filter_operator = 'and'
        end

        def to_s
          self.to_xml
        end

        # ConditionExpression can be repeated multiple times
        # Operator: can be lots of values such as: eq (Equals), neq (Not Equals), gt (Greater Than) 
        #           get the values from a fetch xml query
        # Values -> Value can be repeated multiple times
        # FilterOperator: and OR or depending on the filter requirements
        def to_xml

          expressions = ""
          self.each do |tuple|
ap tuple
            attr_name = tuple[0]
            operator = tuple[1]
            values = tuple[2].is_a?(Array) ? tuple[2] : [tuple[2]]
            type = (tuple[3] || values.first.class).to_s.downcase
            expressions << %Q{<a:ConditionExpression>
                <a:AttributeName>#{attr_name}</a:AttributeName>
                <a:Operator>#{operator}</a:Operator>
                <a:Values xmlns:b="http://schemas.microsoft.com/2003/10/Serialization/Arrays">
              }
                values.each do |v|
                    expressions << %Q{<b:anyType i:type="c:#{type}" xmlns:c="http://www.w3.org/2001/XMLSchema">#{v}</b:anyType>}
                end
                
            expressions << %Q{
                 </a:Values>
            </a:ConditionExpression>}
          end

          %Q{<a:Criteria>
              <a:Conditions>
                #{expressions}
              </a:Conditions>
              <a:FilterOperator></a:FilterOperator>
          </a:Criteria>}
        end
      end
      # ColumnSet
    end
  end
end
