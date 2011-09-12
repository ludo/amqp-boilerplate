require 'logger'

module AMQP
  module Boilerplate
    module Logging
      attr_writer :logger

      def logger
        @logger ||= ::Logger.new(STDOUT)
      end
    end
  end
end
