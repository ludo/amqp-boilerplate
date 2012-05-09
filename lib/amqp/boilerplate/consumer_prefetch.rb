module AMQP
  module Boilerplate
    module ConsumerPrefetch
      attr_writer :consumer_prefetch

      # Wether or not to force loading consumers even if the server_type is not Passenger
      #
      # @see AMQP::Boilerplate.configure
      def consumer_prefetch
        @consumer_prefetch ||= 0
      end
    end
  end
end
