require 'amqp'

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
      load_consumers
      start_consumers
    end

    # TODO Documentation!
    def self.configure
      yield self if block_given?
    end
  end
end
