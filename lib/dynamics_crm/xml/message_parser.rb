require 'ostruct'
require 'rexml/document'

module DynamicsCRM
  module XML
    module MessageParser

      def self.parse_key_value_pairs(parent_element)
        h = {}
        # Get namespace alias (letter) for child elements.
        namespace_alias = parent_element.attributes.keys.first || "c"
        parent_element.each_element do |key_value_pair|

          key_element = key_value_pair.elements["#{namespace_alias}:key"]
          key = key_element.text
          value_element = key_value_pair.elements["#{namespace_alias}:value"]
          value = value_element.text
          begin
            if value_element.attributes['type'].nil?
              h[key] = value
              next
            end

            prefix, type = value_element.attributes['type'].split(':')
            case type
            when "OptionSetValue"
              # Nested value. Appears to always be an integer.
              value = value_element.elements.first.text.to_i
            when "boolean"
              value = (value == "true")
            when "decimal"
              value = value.to_f
            when "dateTime"
              value = Time.parse(value)
            when "EntityReference"
              entity_ref = {}
              value_element.each_element do |child|
                entity_ref[child.name] = child.text
              end
              value = entity_ref
            when "EntityCollection"
              value = XML::EntityCollection.new(value_element)
            when "EntityMetadata", /^\w*AttributeMetadata$/
              value = value_element
            when "ArrayOfEntityMetadata"
              value = value_element.get_elements("#{prefix}:EntityMetadata")
            when "ArrayOfAttributeMetadata"
              value = value_element.get_elements("#{prefix}:AttributeMetadata")
            when "EntityMetadataCollection"
              value = value_element.get_elements("#{prefix}:EntityMetadata")
            when "AliasedValue"
              value = value_element.elements["#{prefix}:Value"].text
            when "Money"
              # Nested value.
              value = value_element.elements.first.text.to_f
            when "int"
              value = value.to_i
            when "string", "guid"
              # nothing
            end
          rescue => e
            # In case there's an error during type conversion.
            puts e.message
          end

          h[key] = value
        end
        h
      end

    end
  end
end
