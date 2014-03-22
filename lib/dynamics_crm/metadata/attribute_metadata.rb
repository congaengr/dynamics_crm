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

    end

  end
end