require 'amqp'
require 'amqp/utilities/event_loop_helper'

require 'amqp/boilerplate/version'

require 'amqp/boilerplate/consumer'
require 'amqp/boilerplate/consumer_prefetch'
require 'amqp/boilerplate/consumer_registry'
require 'amqp/boilerplate/force_consumers'
require 'amqp/boilerplate/logging'
require 'amqp/boilerplate/producer'

module AMQP
  module Boilerplate
    extend ConsumerRegistry
    extend Logging
    extend ForceConsumers
    extend ConsumerPrefetch

    # Opens a channel to AMQP and starts all consumers
    #
    # NOTE When an unknown server type is encountered the consumers will NOT be
    # started. A channel will be opened for the producers though.
    #
    # @see AMQP::Utilities::EventLoopHelper
    # @return [void]
    def self.boot
      if AMQP::Utilities::EventLoopHelper.server_type == :passenger
        ::PhusionPassenger.on_event(:starting_worker_process) do |forked|
          if forked
            Thread.new do
              AMQP::Boilerplate.start
            end
          end
        end
      else
        AMQP::Utilities::EventLoopHelper.run do
          AMQP::Boilerplate.start
        end
      end

      sleep(0.25)

      AMQP::Boilerplate.logger.info("[#{self.name}.boot] Started AMQP (Server Type: #{AMQP::Utilities::EventLoopHelper.server_type || 'unknown'})")

      EventMachine.next_tick do
        AMQP.channel ||= AMQP::Channel.new(AMQP.connection)

        load_consumers

        if AMQP::Utilities::EventLoopHelper.server_type || force_consumers
          start_consumers
        else
          AMQP::Boilerplate.logger.debug("[#{self.name}.boot] Unknown server type, not starting consumers")
        end
      end
    end

    # Configures AMQP::Boilerplate and yields AMQP::Boilerplate object to the block
    #
    # @example
    #   AMQP::Boilerplate.configure do |config|
    #     config.logger = ::Rails.logger
    #     config.consumer_paths += %W( #{Rails.root}/app/consumers )
    #     config.connection_options = { :host => "localhost", :port => 5672, :vhost => Rails.env }
    #     config.on_unhandled_exception = Proc.new { |exception, consumer, metadata, payload| puts "Do something with exceptions: #{exception}" }
    #   end
    def self.configure
      yield self if block_given?
    end

    def self.connection_options
      @connection_options
    end

    # AMQP connection options (:host, :port, :username, :vhost, :password) that
    # will be passed as connection_options to {http://rdoc.info/github/ruby-amqp/amqp/master/AMQP#connect-class_method AMQP#start}
    # when starting an EventMachine event loop.
    def self.connection_options=(options)
      @connection_options = options
    end

    def self.on_unhandled_consumer_exception
      @on_unhandled_consumer_exception
    end

    # Pass a +Proc+ object to this option that will function as a handler for
    # uncaught exceptions in a consumer.
    def self.on_unhandled_consumer_exception=(handler)
      @on_unhandled_consumer_exception = handler
    end

    def self.start
      AMQP.start self.connection_options
    end
  end
end
