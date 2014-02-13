require 'ostruct'
require 'rexml/document'

module Mscrm
  module Soap
    module Model
      class RetrieveResult < Hash

        attr_reader :result_response

        def initialize(xml)

          doc = REXML::Document.new(xml)
          @result_response = doc.get_elements("//RetrieveResult").first

          h = {}
          h["type"] = @result_response.elements["b:LogicalName"].text
          h["id"] = @result_response.elements["b:Id"].text

          @result_response.elements["b:Attributes"].each_element do |key_value_pair|
            key = key_value_pair.elements["c:key"].text
            h[key] = key_value_pair.elements["c:value"].text
          end
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
