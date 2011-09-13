module AMQP
  module Boilerplate
    # Use this module to turn a class into a potential producer that can
    # deliver messages to an AMQP exchange.
    #
    # @example Getting started
    #   class MyProducer
    #     extend AMQP::Boilerplate::Producer
    #
    #     amqp :routing_key => "hello.world"
    #     amqp_message :message
    #
    #     def message
    #       "Look! I am a string that will be posted to the exchange."
    #     end
    #   end
    #
    # @example Configuring exchange
    #   class MyProducer
    #     extend AMQP::Boilerplate::Producer
    #
    #     amqp :routing_key => "hello.world"
    #     amqp_exchange :fanout, "amq.fanout", :durable => true
    #     amqp_message :message
    #
    #     def message
    #       "Look! I am a string that will be posted to the exchange."
    #     end
    #   end
    module Producer
      # Macro that sets up amqp for a class.
      #
      # @param [Hash] opts Options that will be passed to +AMQP::Exchange#publish
      # @return [void]
      def amqp(opts={})
        send :include, InstanceMethods
        @amqp_boilerplate_options = opts
      end

      # Configuration for the exchange to be used
      #
      # @param [Symbol] type Exchange type
      # @param [String] name Exchange name
      # @param [Hash] opts a customizable set of options
      # @see AMQP::Exchange#initialize
      # @return [void]
      def amqp_exchange(type=:direct, name=AMQ::Protocol::EMPTY_STRING, opts={})
        @amqp_boilerplate_exchange = [type, name, opts]
      end

      # Choose the method that will return the actual message (payload) to be
      # delivered to the exchange
      #
      # This method SHOULD return a string.
      #
      # @param [Symbol] method_name Name of method that generates message
      # @return [void]
      def amqp_message(method_name)
        @amqp_boilerplate_message = method_name
      end

      # TODO Can we do this in a nicer way?
      def amqp_boilerplate_options
        @amqp_boilerplate_options
      end

      # TODO Can we do this in a nicer way?
      def amqp_boilerplate_exchange
        @amqp_boilerplate_exchange || amqp_exchange
      end

      # TODO Can we do this in a nicer way?
      def amqp_boilerplate_message
        @amqp_boilerplate_message
      end

      module InstanceMethods
        # Publishes a message to the exchange
        #
        # @see AMQP::Exchange#publish
        # @return [void]
        def publish
          message = send(self.class.amqp_boilerplate_message.to_sym)
          exchange.publish(message, self.class.amqp_boilerplate_options) do
            AMQP::Boilerplate.logger.debug "[#{self.class}] Published message:\n#{message}"
          end
        end

      private

        # Instantiates a new exchange, additional configuration can be given
        # through the +amqp_exchange+ class macro.
        #
        # @see AMQP::Exchange#initialize
        # @return [AMQP::Exchange]
        def exchange
          AMQP::Exchange.new(AMQP.channel, *self.class.amqp_boilerplate_exchange)
        end
      end
    end
  end
end
