module DynamicsCRM
  module Metadata

    class PropertiesExpression
      attr_accessor :properties

      def initialize(properties=[])
        @properties = properties
      end

      def to_xml(options={})
        namespace = options[:namespace] ? options[:namespace] + ":" : ""

        property_set = ''
        if @properties.any?
          property_set = %Q{<#{namespace}PropertyNames xmlns:e="http://schemas.microsoft.com/2003/10/Serialization/Arrays">}
          @properties.each do |name|
            property_set << "<e:string>#{name}</e:string>"
          end
          property_set << "</#{namespace}PropertyNames>"
        end

        %Q{<#{namespace}Properties>
             <#{namespace}AllProperties>#{property_set.empty?}</#{namespace}AllProperties>
             #{property_set}
           </#{namespace}Properties>}
      end
    end
  end
end
