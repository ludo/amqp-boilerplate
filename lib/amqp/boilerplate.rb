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

      AMQP::Boilerplate.logger.info("[#{self.name}.boot] Started AMQP (Server Type: #{AMQP::Utilities::EventLoopHelper.server_type})")

      EventMachine.next_tick do
        AMQP.channel ||= AMQP::Channel.new(AMQP.connection)

        load_consumers
        start_consumers
      end
    end

    # Configures AMQP::Boilerplate and yields AMQP::Boilerplate object to the block
    #
    # @example
    #   AMQP::Boilerplate.configure do |config|
    #     config.logger = ::Rails.logger
    #     config.consumer_paths += %W( #{Rails.root}/app/consumers )
    #     config.connection_options = { :host => "localhost", :port => 5672, :vhost => Rails.env }
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

    def self.start
      AMQP.start self.connection_options
    end
  end
end
