require 'spec_helper'

# NOTE See spec_helper for Producer definitions
describe AMQP::Boilerplate::Producer do
  before(:each) do
    AMQP::Boilerplate.stub(:logger).and_return(mock.as_null_object)

    @exchange = mock(AMQP::Exchange)
    @exchange.stub(:publish).and_yield
    AMQP::Exchange.stub!(:new).and_return(@exchange)

    @producer = BarProducer.new
  end

  describe ".amqp_exchange" do
    it "should default amqp_exchange attributes" do
      another_producer = FooProducer.new
      AMQP::Exchange.should_receive(:new).with(AMQP.channel, :direct, AMQ::Protocol::EMPTY_STRING, {})
      another_producer.publish
    end
  end

  describe "#publish" do
    it "should use an exchange" do
      @producer.should_receive(:exchange).and_return(@exchange)
      @producer.publish
    end

    it "should publish to exchange" do
      @exchange.should_receive(:publish)
      @producer.publish
    end

    it "should publish to the exchange using the proper routing_key" do
      @exchange.should_receive(:publish).with(@producer.message, :routing_key => "some.routing.key")
      @producer.publish

      another_producer = FooProducer.new
      @exchange.should_receive(:publish).with(another_producer.some_method, :routing_key => "another.routing.key")
      another_producer.publish
    end

    it "should only log nil messages" do
      @nilproducer = NilProducer.new
      AMQP::Boilerplate.logger.should_receive(:debug).with("[#{@nilproducer.class}] Not publishing nil message")
      @nilproducer.publish
    end


    it "should pass options to AMQP::Exchange#publish" do
      BarProducer.amqp({ :routing_key => "some.routing.key", :mandatory => true })
      @exchange.should_receive(:publish).with(@producer.message, :routing_key => "some.routing.key", :mandatory => true)
      @producer.publish

      BarProducer.amqp({ :routing_key => "some.routing.key", :mandatory => true, :immediate => true })
      @exchange.should_receive(:publish).with(@producer.message, :routing_key => "some.routing.key", :mandatory => true, :immediate => true)
      @producer.publish
    end

    describe "connecting to exchange" do
      before(:each) do
        @channel = mock(AMQP::Channel)
        AMQP.stub(:channel).and_return(@channel)
      end

      it "should instantiate an exchange" do
        AMQP::Exchange.should_receive(:new)
        @producer.publish
      end

      it "should connect to the exchange" do
        AMQP::Exchange.should_receive(:new).with(@channel, :fanout, "amq.fanout", { :durable => true })
        @producer.publish
      end

      it "should use defaults for exchange configuration" do
        BarProducer.amqp_exchange()

        AMQP::Exchange.should_receive(:new).with(@channel, :direct, AMQ::Protocol::EMPTY_STRING, {})
        @producer.publish
      end
    end

    it "should log after delivering message" do
      AMQP::Boilerplate.logger.should_receive(:debug).with("[#{@producer.class}] Published message:\n#{@producer.message}")
      @producer.publish
    end
  end
end
