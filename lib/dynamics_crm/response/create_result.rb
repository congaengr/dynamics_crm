module DynamicsCRM
  module Response

    class CreateResult < Result

      protected

      # Invoked by Result constructor
      def parse_result_response(result)
        {"Id" => result.text, "id" => result.text}
      end
    end

  end
end
