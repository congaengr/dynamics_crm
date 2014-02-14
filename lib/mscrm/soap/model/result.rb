require 'ostruct'
require 'rexml/document'

module Mscrm
  module Soap
    module Model
      class Result < Hash

        attr_reader :result_response

        def initialize(xml)

          doc = REXML::Document.new(xml)
          class_name = self.class.to_s.split("::").last
          @result_response = doc.get_elements("//#{class_name}").first

          h = parse_result_response(@result_response)

          # Calling super causes undesired behavior so just merge.
          self.merge!(h)
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
          parent_element.each_element do |key_value_pair|
            key_element = key_value_pair.elements["c:key"]
            key = key_element.text
            value_element = key_value_pair.elements["c:value"]
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
    end
  end
end
