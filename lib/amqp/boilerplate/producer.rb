module AMQP
  module Boilerplate
    # Use this module to turn a class into a potential producer that can
    # deliver messages to an AMQP exchange.
    #
    # You turn your class into a producer by extending the module
    # and call the required macros {#amqp} and {#amqp_message} methods.
    #
    # To specify exchange options you can call the optional macro {#amqp_exchange} method.
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
      # @param [Hash] opts Options that will be passed as options to {http://rdoc.info/github/ruby-amqp/amqp/master/AMQP/Exchange#publish-instance_method AMQP::Exchange#publish}
      # @return [void]
      def amqp(opts={})
        send :include, InstanceMethods
        @amqp_boilerplate_options = opts
      end

      # Configuration for the exchange to be used
      #
      # @param [Symbol] type Exchange type
      #
      #   There are 4 supported exchange types: direct, fanout, topic and headers. Exchange type determines how exchange processes and routes messages.
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
      # @example
      #   amqp_message :message
      #
      #   def message
      #     "Look! I am a string that will be posted to the exchange."
      #   end
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
        def publish(&block)
          block ||= lambda {
            AMQP::Boilerplate.logger.debug "[#{self.class}] Message was published"
          }

          message = send(self.class.amqp_boilerplate_message.to_sym)
          if message
            AMQP::Boilerplate.logger.debug "[#{self.class}] Publishing message:\n#{message}"
            exchange.publish(message, self.class.amqp_boilerplate_options, &block)
          else
            AMQP::Boilerplate.logger.debug "[#{self.class}] Not publishing nil message"
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
