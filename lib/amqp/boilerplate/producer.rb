module AMQP
  module Boilerplate
    module Producer
      def amqp(options={})
        send :include, InstanceMethods
        @amqp_boilerplate_options = options
      end

      def amqp_exchange(type=:direct, name=AMQ::Protocol::EMPTY_STRING, options={})
        @amqp_boilerplate_exchange = [type, name, options]
      end

      def amqp_message(method_name)
        @amqp_boilerplate_message = method_name
      end

      def amqp_boilerplate_options
        @amqp_boilerplate_options
      end

      def amqp_boilerplate_exchange
        @amqp_boilerplate_exchange || amqp_exchange
      end

      def amqp_boilerplate_message
        @amqp_boilerplate_message
      end

      module InstanceMethods
        def publish
          message = send(self.class.amqp_boilerplate_message.to_sym)
          exchange.publish(message, self.class.amqp_boilerplate_options) do
            AMQP::Boilerplate.logger.debug "[#{self.class}] Published message:\n#{message}"
          end
        end

      private

        def exchange
          AMQP::Exchange.new(AMQP.channel, *self.class.amqp_boilerplate_exchange)
        end
      end
    end
  end
end
