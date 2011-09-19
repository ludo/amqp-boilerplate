module AMQP
  module Boilerplate
    # Inherit from this class to turn a class into a potential consumer that can
    # handle messages delivered to them by AMQP broker.
    #
    # You should call the macro {.amqp_queue} method and implement {#handle_message}.
    #
    # To specify subscription options you can call the optional macro {.amqp_subscription} method.
    #
    # @example Basic consumer
    #   class MyConsumer < AMQP::Boilerplate::Consumer
    #     amqp_queue "hello.world"
    #
    #     def handle_message(payload, metadata)
    #       puts "Received message: #{payload}"
    #     end
    #   end
    #
    # @example Configuring subscription
    #   class MyConsumer < AMQP::Boilerplate::Consumer
    #     amqp_queue "queue.name.here", :durable => true
    #     amqp_subscription :ack => true
    #
    #     def handle_message(payload, metadata)
    #       puts "Received message: #{payload}"
    #     end
    #   end
    class Consumer
      class << self
        # Macro for selecting exchange to bind to
        #
        # @param [String] name Exchange name
        # @return [void]
        def amqp_exchange(name)
          @exchange_name = name
        end

        # Macro that sets up the amqp_queue for a class.
        #
        # @param [String] name Queue name. If you want a server-named queue, you can omit the name.
        # @param [Hash] options Options that will be passed as options to {http://rdoc.info/github/ruby-amqp/amqp/master/AMQP/Channel#queue-instance_method AMQP::Channel#queue}
        # @return [void]
        def amqp_queue(name=AMQ::Protocol::EMPTY_STRING, options={})
          @queue_name = name
          @queue_options = options
          AMQP::Boilerplate.register_consumer(self)
        end

        # Macro that sets the routing key for this consumer.
        #
        # @param [String] the routing key
        def amqp_routing_key(key)
          @routing_key = key
        end

        # Macro that subscribes to asynchronous message delivery.
        # 
        # @param [Hash] options Options that will be passed as options to {http://rdoc.info/github/ruby-amqp/amqp/master/AMQP/Queue#subscribe-instance_method AMQP::Queue#subscribe}
        def amqp_subscription(options={})
          @subscription_options = options
        end

        def start
          consumer = new

          channel = AMQP.channel
          channel.on_error(&consumer.method(:handle_channel_error))

          queue = channel.queue(@queue_name, @queue_options)
          queue.bind(@exchange_name, @routing_key ? {:routing_key => @routing_key} : {}) if @exchange_name
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
