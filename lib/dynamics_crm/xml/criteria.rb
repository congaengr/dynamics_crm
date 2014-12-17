module DynamicsCRM
  module XML

    class Criteria < Array

      attr_accessor :filter_operator
      def initialize(tuples=[])
        super
        @filter_operator = 'And'
      end

      # ConditionExpression can be repeated multiple times
      # Operator: can be lots of values such as: eq (Equals), neq (Not Equals), gt (Greater Than) 
      #           get the values from a fetch xml query
      # Values -> Value can be repeated multiple times
      # FilterOperator: and OR or depending on the filter requirements
      def toooooooo_xml(options={})
        ns = options[:namespace] ? options[:namespace] : "a"

        expressions = ""
        self.each do |tuple|
          attr_name = tuple[0]
          operator = tuple[1]
          values = tuple[2].is_a?(Array) ? tuple[2] : [tuple[2]]
          # TODO: Improve type detection
          type = (tuple[3] || values.first.class).to_s.downcase
          type = "int" if type == "fixnum"
          type = "boolean" if ["trueclass", "falseclass"].include?(type)

          expressions << %Q{<#{ns}:ConditionExpression>
              <#{ns}:AttributeName>#{attr_name}</#{ns}:AttributeName>
              <#{ns}:Operator>#{operator}</#{ns}:Operator>
              <#{ns}:Values xmlns:d="http://schemas.microsoft.com/2003/10/Serialization/Arrays">
            }
              values.each do |v|
                  expressions << %Q{<d:anyType i:type="s:#{type}" xmlns:s="http://www.w3.org/2001/XMLSchema">#{v}</d:anyType>}
              end
              
          expressions << %Q{
               </#{ns}:Values>
          </#{ns}:ConditionExpression>}
        end

        %Q{<#{ns}:Criteria>
            <#{ns}:Conditions>
              #{expressions}
            </#{ns}:Conditions>
            <#{ns}:FilterOperator>#{@filter_operator}</#{ns}:FilterOperator>
        </#{ns}:Criteria>}
      end
    end
    # Criteria
  end
end
