require 'logger'

module AMQP
  module Boilerplate
    module Logging
      attr_writer :logger

      # Returns the logger used to write logging output to.
      # You can define the logger when you configure +AMQP::Boilerplate+ if you want to use a different logger than the default Ruby Logger.
      #
      # @see AMQP::Boilerplate.configure
      def logger
        @logger ||= ::Logger.new(STDOUT)
      end
    end
  end
end
