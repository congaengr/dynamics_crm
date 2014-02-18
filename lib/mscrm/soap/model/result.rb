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
            string_method = StringUtil.underscore(string_method)
            value = self[string_method] || self[string_method.to_sym]
          end

          # Finally return nil.
          return value
        end

        def respond_to_missing?(method_name, include_private = false)
          self.has_key?(method_name.to_s) || self.has_key?(method_name) || super
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
