module Mscrm
  module Soap
    module Model
      class Attributes < Array

        def initialize(hash)

          hash.each do |key,value|
            type = "string"

            case value.class
            when Fixnum
              type = "int"
            when Float
              type = "decimal"
            when TrueClass, FalseClass
              type = "boolean"
            when Time, DateTime
              type = "dateTime"
            when Hash
              type = "EntityReference"
            end
            # Not sure how to handle OptionSetValue or Money
            if type == "string" && value =~ /\w+{8}-\w+{4}-\w+{4}-\w+{4}-\w+{12}/
              type = "guid"
            end

            self << build_xml(key, value, type)
          end
        end

        def to_xml
          xml = '<a:Attributes xmlns:b="http://schemas.datacontract.org/2004/07/System.Collections.Generic">'
          self.each do |el|
            xml << el
          end
          xml << "\n</a:Attributes>"
        end

        def to_s
          self.to_xml
        end

        def build_xml(key, value, type)

          xml = %Q{
            <a:KeyValuePairOfstringanyType>
              <b:key>#{key}</b:key>}

          case type
          when "EntityReference"
            xml << %Q{
              <b:value i:type="a:EntityReference">
                  <a:Id>#{value[:guid]}</a:Id>
                  <a:LogicalName>#{value[:entity_name]}</a:LogicalName>
                  <a:Name #{value[:name] ? '' : 'i:nil="true"'}>#{value[:name]}</a:Name>
              </b:value>
            }
          when "OptionSetValue", "Money"
            xml << %Q{
                <b:value i:type="a:#{type}">
                  <a:Value>#{value}</a:Value>
                </b:value>
            }
          else
            xml << %Q{
                <b:value i:type="c:#{type}" xmlns:c="http://www.w3.org/2001/XMLSchema">#{value}</b:value>
            }
          end
          xml << "</a:KeyValuePairOfstringanyType>"

          xml
        end

      end
    end
  end
end