module Mscrm
  module Soap
    module Metadata

      class AttributeMetadata < XmlDocument

        # PicklistAttributeMetadata
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
end