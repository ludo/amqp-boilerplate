module AMQP
  module Boilerplate
    module ConsumerRegistry
      def load_consumers
        consumer_paths.each do |dir|
          Dir[File.join(dir, "*.rb")].each {|f| require f}
        end
      end

      def consumer_paths
        @consumer_paths ||= []
      end

      def registry
        @registry ||= []
      end

      def register_consumer(klass)
        AMQP::Boilerplate.logger.info("[#{self.name}#register_consumer] Registered consumer '#{klass.name}'")
        registry << klass
      end

      def start_consumers
        registry.each do |consumer|
          consumer.start
        end
      end
    end
  end
end
