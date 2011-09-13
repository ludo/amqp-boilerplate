require 'amqp'

require 'amqp/boilerplate/version'

require 'amqp/boilerplate/consumer'
require 'amqp/boilerplate/logging'
require 'amqp/boilerplate/producer'

module AMQP
  module Boilerplate
    extend Logging

    # TODO Documentation!
    def self.configure
      yield self if block_given?
    end
  end
end
