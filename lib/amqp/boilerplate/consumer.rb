module AMQP
  module Boilerplate
    # @example Basic consumer
    #   class MyConsumer < AMQP::Boilerplate::Consumer
    #     amqp_queue "hello.world"
    #
    #     def handle_message(payload, metadata)
    #       puts "Received message: #{payload}"
    #     end
    #   end
    class Consumer
      class << self
        def amqp_queue(name=AMQ::Protocol::EMPTY_STRING, options={})
          @queue_name = name
          @queue_options = options
          AMQP::Boilerplate.register_consumer(self)
        end

        def amqp_subscription(options={})
          @subscription_options = options
        end

        def start
          consumer = new

          channel = AMQP.channel
          channel.on_error(&consumer.method(:handle_channel_error))

          queue = channel.queue(@queue_name, @queue_options)
          queue.subscribe(@subscription_options, &consumer.method(:handle_message))

          AMQP::Boilerplate.logger.info("[#{self.name}.start] Started consumer '#{self.name}'")
        end
      end

      def handle_message(metadata, payload)
        raise NotImplementedError, "The time has come to implement your own consumer class. Good luck!"
      end

      def handle_channel_error(channel, channel_close)
        AMQP::Boilerplate.logger.error("[#{self.class}#handle_channel_error] Code = #{channel_close.reply_code}, message = #{channel_close.reply_text}")
      end
    end
  end
end
