require 'ostruct'
require 'rexml/document'

module Mscrm
  module Soap
    module Model
      class Result < Hash

        attr_reader :result_response

        def initialize(xml)

          doc = REXML::Document.new(xml)

          fault_xml = doc.get_elements("//[local-name() = 'Fault']")
          raise Fault.new(fault_xml) if fault_xml.any?

          class_name = self.class.to_s.split("::").last
          @result_response = doc.get_elements("//#{class_name}").first

          # Child classes should override this method.
          h = parse_result_response(@result_response)

          # Calling super causes undesired behavior so just merge.
          self.merge!(h)
        end

        # Invoked by constructor, should be implemented in sub-classes.
        def parse_result_response(result)
          # do nothing here
          {}
        end

        # Allows method-like access to the hash using camelcase field names.
        def method_missing(method, *args, &block)

          # First return local hash entry for symbol or string.
          return self[method] if self.has_key?(method)

          string_method = method.to_s
          return self[string_method] if self.has_key?(string_method)

          value = nil
          # Then check if string converted to underscore finds a match.
          if string_method =~ /[A-Z+]/
            string_method = underscore(string_method)
            value = self[string_method] || self[string_method.to_sym]
          end

          # Finally return nil.
          return value
        end

        def respond_to_missing?(method_name, include_private = false)
          self.has_key?(method_name.to_s) || self.has_key?(method_name) || super
        end

      protected

        def parse_key_value_pairs(parent_element)
          h = {}
          # Get namespace alias (letter) for child elements.
          namespace_alias = parent_element.attributes.keys.first
          parent_element.each_element do |key_value_pair|

            key_element = key_value_pair.elements["#{namespace_alias}:key"]
            key = key_element.text
            value_element = key_value_pair.elements["#{namespace_alias}:value"]
            value = value_element.text

            begin

              case value_element.attributes["type"]
              when "b:OptionSetValue"
                # Nested value. Appears to always be an integer.
                value = value_element.elements.first.text.to_i
              when "d:boolean"
                value = (value == "true")
              when "d:decimal"
                value = value.to_f
              when "d:dateTime"
                value = Time.parse(value)
              when "b:EntityReference"
                entity_ref = {}
                value_element.each_element do |child|
                  entity_ref[child.name] = child.text
                end
                value = entity_ref
              when "b:Money"
                # Nested value.
                value = value_element.elements.first.text.to_f
              when "d:int"
                value = value.to_i
              when "d:string", "d:guid"
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

        def underscore(str)
          str.gsub(/::/, '/').
            gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
            gsub(/([a-z\d])([A-Z])/,'\1_\2').
            tr("-", "_").
            downcase
        end

      end

      # There's nothing to parse in the DeleteResult
      class UpdateResult < Result
      end

      # There's nothing to parse in the DeleteResult
      class DeleteResult < Result
      end

    end
  end
end
