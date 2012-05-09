require 'rspec'

require 'amqp/boilerplate'

RSpec.configure do |c|
  c.mock_with :rspec
end

# "Test" consumers
class FooConsumer < AMQP::Boilerplate::Consumer
  amqp_queue
end

class BarConsumer < AMQP::Boilerplate::Consumer
  amqp_queue "queue.name.here", :durable => true
  amqp_subscription :ack => true
  amqp_channel :prefetch => 1
end

# "Test" producers
class FooProducer
  extend AMQP::Boilerplate::Producer

  amqp :routing_key => "another.routing.key"
  amqp_message :some_method

  def some_method
    'Foo Bar'
  end
end

class NilProducer
  extend AMQP::Boilerplate::Producer

  amqp :routing_key => "yet.another.routing.key"
  amqp_message :nil_message

  def nil_message
    nil
  end
end

class BarProducer
  extend AMQP::Boilerplate::Producer

  amqp :routing_key => "some.routing.key"
  amqp_exchange :fanout, "amq.fanout", { :durable => true }
  amqp_message :message

  def message
    "hello world!"
  end
end

