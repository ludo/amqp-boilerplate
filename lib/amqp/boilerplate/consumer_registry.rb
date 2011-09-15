module AMQP
  module Boilerplate
    module ConsumerRegistry
      attr_writer :consumer_paths

      # Returns an array of paths which files are loaded when {AMQP::Boilerplate.boot} is called.
      # You should define the consumer_paths when you configure +AMQP::Boilerplate+ and assign
      # an array of paths pointing to the folder where your consumer files are located, to it. 
      #
      # @see AMQP::Boilerplate.configure
      def consumer_paths
        @consumer_paths ||= []
      end

      def load_consumers
        consumer_paths.each do |dir|
          Dir[File.join(dir, "*.rb")].each {|f| require f}
        end
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
