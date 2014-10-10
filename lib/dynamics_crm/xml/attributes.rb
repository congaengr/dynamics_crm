module DynamicsCRM
  module XML

    class Attributes < Hash

      def initialize(attrs)
        super
        self.merge!(attrs)
      end

      def get_type(key, value)
        type = "string"
        case value
          when ::Fixnum
            type = "int"
          when ::BigDecimal, ::Float
            type = "decimal"
          when ::TrueClass, ::FalseClass
            type = "boolean"
          when ::Time, ::DateTime
            type = "dateTime"
          when ::Hash, EntityReference
            type = "EntityReference"
          when Entity
            type = "Entity"
          when Query
            type = "QueryExpression"
          when FetchExpression
            type = "FetchExpression"
          else
            if key.to_s == "EntityFilters"
              type = "EntityFilters"
            elsif key.to_s == "RollupType"
              type = "RollupType"
            end
        end

        if type == "string" && value =~ /\w+{8}-\w+{4}-\w+{4}-\w+{4}-\w+{12}/
          type = "guid"
        end

        type
      end

      # Removes Attributes class wrapper.
      def to_hash
        raw_hash = {}
        self.each do |key, value|
          raw_hash[key] = value
        end
        raw_hash
      end

      def to_xml
        xml = %Q{<a:#{self.class_name} xmlns:c="http://schemas.datacontract.org/2004/07/System.Collections.Generic">}

        self.each do |key,value|

          # Temporary hack to handle types I cannot infer (OptionSetValue or Money).
          if value.is_a?(Hash) && !value[:type].nil?
            type = value[:type]
            value = value[:value]
          else
            type = get_type(key, value)
          end

          xml << build_xml(key, value, type)
        end

        xml << %Q{\n</a:#{self.class_name}>}
      end

      def to_s
        self.to_hash
      end

      def build_xml(key, value, type)

        xml = %Q{
          <a:KeyValuePairOfstringanyType>
            <c:key>#{key}</c:key>
          }

        # If we have an object that can convert itself, use it.
        if (value.respond_to?(:to_xml) && value.class.to_s.include?("DynamicsCRM"))
          xml <<  "<c:value i:type=\"a:#{type}\">\n" << value.to_xml({exclude_root: true, namespace: 'a'}) << "</c:value>"
        else
          xml << render_value_xml(type, value)
        end

        xml << "\n</a:KeyValuePairOfstringanyType>"

        xml
      end

      def render_value_xml(type, value)
        xml = ""
        case type
        when "EntityReference"
          xml << %Q{
            <c:value i:type="a:EntityReference">
                <a:Id>#{value[:id]}</a:Id>
                <a:LogicalName>#{value[:logical_name]}</a:LogicalName>
                <a:Name #{value[:name] ? '' : 'i:nil="true"'}>#{value[:name]}</a:Name>
            </c:value>
          }
        when "OptionSetValue", "Money"
          xml << %Q{
              <c:value i:type="a:#{type}">
                <a:Value>#{value}</a:Value>
              </c:value>
          }
        else
          s_namespace = "http://www.w3.org/2001/XMLSchema"
          if ["EntityFilters"].include?(type)
            s_namespace = "http://schemas.microsoft.com/xrm/2011/Metadata"
          end

          if type == "guid"
            xml << %Q{
              <c:value xmlns:d="http://schemas.microsoft.com/2003/10/Serialization/" i:type="d:guid">#{value}</c:value>
            }
          elsif type == "RollupType"
            xml << %Q{
              <c:value i:type="a:RollupType">#{value}</c:value>
            }
          elsif type == "dateTime"
            xml << %Q{
              <c:value i:type="s:#{type}" xmlns:s="http://www.w3.org/2001/XMLSchema">#{value.utc.strftime('%Y-%m-%dT%H:%M:%SZ')}</c:value>
            }
          else
            xml << %Q{
              <c:value i:type="s:#{type}" xmlns:s="#{s_namespace}">#{value}</c:value>
            }
          end
        end

        xml
      end

      def class_name
        self.class.to_s.split("::").last
      end

      def self.from_xml(xml_document)
        hash = MessageParser.parse_key_value_pairs(xml_document)
        if xml_document.name == "FormattedValues"
          return FormattedValues.new(hash)
        elsif xml_document.name == "Parameters"
          return Parameters.new(hash)
        else
          return Attributes.new(hash)
        end
      end

      # Allows method-like access to the hash (OpenStruct)
      def method_missing(method_name, *args, &block)
        # Return local hash entry if any.
        return self[method_name.to_s]
      end

      def respond_to_missing?(method_name, include_private = false)
        self.has_key?(method_name.to_s) || super
      end

    end

    class Parameters < Attributes; end
    class FormattedValues < Attributes; end
  end

end