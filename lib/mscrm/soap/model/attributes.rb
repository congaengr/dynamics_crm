module Mscrm
  module Soap
    module Model

      class Attributes < Hash

        def initialize(attrs)
          super
          self.merge!(attrs)
        end

        def get_type(key, value)
          type = "string"
          case value
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
            else
              if key.to_s == "EntityFilters"
                type = "EntityFilters"
              end
          end

          # Not sure how to handle OptionSetValue or Money
          if type == "string" && value =~ /\w+{8}-\w+{4}-\w+{4}-\w+{4}-\w+{12}/
            type = "guid"
          end

          type
        end

        def to_xml
          xml = %Q{<a:#{self.class_name} xmlns:b="http://schemas.datacontract.org/2004/07/System.Collections.Generic">}

          self.each do |key,value|
            type = get_type(key, value)
            xml << build_xml(key, value, type)
          end

          xml << %Q{\n</a:#{self.class_name}>}
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
            if ["EntityFilters"].include?(type)
              c_namespace = "http://schemas.microsoft.com/xrm/2011/Metadata"
            else
              c_namespace = "http://www.w3.org/2001/XMLSchema"
            end

            xml << %Q{
                <b:value i:type="c:#{type}" xmlns:c="#{c_namespace}">#{value}</b:value>
            }
          end
          xml << "</a:KeyValuePairOfstringanyType>"

          xml
        end

        def class_name
          self.class.to_s.split("::").last
        end

        def self.from_xml(xml_document)
          hash = MessageParser.parse_key_value_pairs(xml_document)
          attributes = Attributes.new(hash)
        end
      end

      class Parameters < Attributes; end
    end
  end
end