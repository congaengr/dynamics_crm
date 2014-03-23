module DynamicsCRM
  module Model
    class Opportunity < Entity
      def initialize(id, client)
        super("opportunity", id, client)
      end

      def set_as_won
        self.send_status("WinOpportunity")
      end

      def set_as_lost
        self.send_status("LoseOpportunity")
      end

      protected

      def send_status(message_type, status=-1)
        entity = DynamicsCRM::XML::Entity.new("opportunityclose")
        entity.attributes = DynamicsCRM::XML::Attributes.new(
          opportunityid: DynamicsCRM::XML::EntityReference.new(@logical_name, @id)
        )

        response = @client.execute(message_type, {
          OpportunityClose: entity,
          Status: {type: "OptionSetValue", value: -1}
        })
      end
    end
  end
end