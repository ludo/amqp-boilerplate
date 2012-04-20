module AMQP
  module Boilerplate
    module ForceConsumers
      attr_writer :force_consumers

      # Wether or not to force loading consumers even if the server_type is not Passenger
      #
      # @see AMQP::Boilerplate.configure
      def force_consumers
        @force_consumers ||= false
      end
    end
  end
end
