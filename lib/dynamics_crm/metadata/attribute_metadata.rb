module DynamicsCRM
  module Metadata

    # AttributeMetadata
    # ManagedPropertyAttributeMetadata
    # IntegerAttributeMetadata
    # BooleanAttributeMetadata
    # DateTimeAttributeMetadata
    # DecimalAttributeMetadata
    # DoubleAttributeMetadata
    # EntityNameAttributeMetadata
    # MoneyAttributeMetadata
    # StringAttributeMetadata
    # LookupAttributeMetadata
    # MemoAttributeMetadata
    # BigIntAttributeMetadata
    # PicklistAttributeMetadata
    # StateAttributeMetadata
    # StatusAttributeMetadata
    #
    # http://msdn.microsoft.com/en-us/library/microsoft.xrm.sdk.metadata.attributemetadata.aspx
    class AttributeMetadata < XmlDocument

      # Only applicable to PicklistAttributeMetadata
      def picklist_options
        return @picklist_options if @picklist_options

        @picklist_options = {}
        option_metadata = "./d:OptionSet/d:Options/d:OptionMetadata"
        @document.get_elements(option_metadata).each do |option|
          numeric_value = option.elements["d:Value"].text
          label = option.elements["d:Label/b:UserLocalizedLabel/b:Label"].text
          @picklist_options[numeric_value.to_i] = label
        end

        @picklist_options
      end

      def type
        return @type if @type

        type_metadata = "./d:AttributeType"
        @type = @document.get_text(type_metadata).to_s
      end

      def logical_name
        return @logical_name if @logical_name

        logical_name_metadata = "./d:LogicalName"
        @logical_name = @document.get_text(logical_name_metadata).to_s
      end

      def display_name
        return @display_name if @display_name

        display_name_metadata = "./d:DisplayName/b:LocalizedLabels/b:LocalizedLabel/b:Label"
        @display_name = @document.get_text(display_name_metadata).to_s
      end

      def attribute_of
        return @attribute_of if @attribute_of

        attribute_of_metadata = "./d:AttributeOf"
        @attribute_of = @document.get_text(attribute_of_metadata).to_s
      end

      def required_level
        return @required_level if @required_level

        required_level_metadata = "./d:RequiredLevel/b:Value"
        @required_level = @document.get_text(required_level_metadata).to_s
      end
    end
  end
end
