require 'amqp'
require 'amqp/utilities/event_loop_helper'

require 'amqp/boilerplate/version'

require 'amqp/boilerplate/consumer'
require 'amqp/boilerplate/consumer_registry'
require 'amqp/boilerplate/logging'
require 'amqp/boilerplate/producer'

module AMQP
  module Boilerplate
    extend ConsumerRegistry
    extend Logging

    def self.boot
      if defined?(PhusionPassenger)
        PhusionPassenger.on_event(:starting_worker_process) do |forked|
          if forked
            amqp_thread = Thread.new {
              AMQP.start
            }
            amqp_thread.abort_on_exception = true
          end
        end
      else
        AMQP::Utilities::EventLoopHelper.run do
          AMQP.start
        end
      end

      sleep(0.25)

      AMQP::Boilerplate.logger.info("[#{self.name}.boot] Started AMQP (Server Type: #{AMQP::Utilities::EventLoopHelper.server_type})")

      EventMachine.next_tick do
        AMQP.channel ||= AMQP::Channel.new(AMQP.connection)

        load_consumers
        start_consumers
      end
    end

    # TODO Documentation!
    def self.configure
      yield self if block_given?
    end

    def self.connection_options
      @connection_options
    end

    def self.connection_options=(options)
      @connection_options = options
    end
  end
end
