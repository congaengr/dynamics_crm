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

        option_path = "./d:OptionSet/d:Options/d:OptionMetadata/d:Label/b:UserLocalizedLabel/b:Label"
        @picklist_options ||= @document.get_elements(option_path).collect do |label|
          label.text
        end
      end

    end

  end
end