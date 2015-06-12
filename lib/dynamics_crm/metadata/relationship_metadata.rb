module DynamicsCRM
  module Metadata
    # This class is expected to be included with EntityMetadata and supports loading of relationships
    # http://msdn.microsoft.com/en-us/library/microsoft.xrm.sdk.metadata.relationshipmetadata.aspx
    module RelationshipMetadata

      # OneToManyRelationships => OneToManyRelationshipMetadata
      def one_to_many
        return @one_to_many if @one_to_many

        @one_to_many = []
        relationship_element = "./d:OneToManyRelationships/d:OneToManyRelationshipMetadata"
        @document.get_elements(relationship_element).each do |metadata|
          @one_to_many << OneToManyRelationship.new(self, metadata)
        end

        @one_to_many
      end

      # ManyToOneRelationships => OneToManyRelationshipMetadata
      def many_to_one
        return @many_to_one if @many_to_one

        @many_to_one = []
        relationship_element = "./d:ManyToOneRelationships/d:OneToManyRelationshipMetadata"
        @document.get_elements(relationship_element).each do |metadata|
          @many_to_one << OneToManyRelationship.new(self, metadata)
        end

        @many_to_one
      end

      # ManyToManyRelationships => ManyToManyRelationshipMetadata
      def many_to_many
        return @many_to_many if @many_to_many

        @many_to_many = []
        relationship_element = "./d:ManyToManyRelationships/d:ManyToManyRelationshipMetadata"
        @document.get_elements(relationship_element).each do |metadata|
          @many_to_many << ManyToManyRelationship.new(self, metadata)
        end
        @many_to_many
      end

    end

  end
end