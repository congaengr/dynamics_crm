module DynamicsCRM
  module Model
    class Entity
      attr_reader :logical_name, :id
      attr_accessor :client

      def initialize(logical_name, id, client)
        @logical_name = logical_name
        @id = id
        @client = client
      end
    end
  end
end