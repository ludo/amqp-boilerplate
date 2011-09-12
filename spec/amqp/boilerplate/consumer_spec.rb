require 'spec_helper'

class DummyConsumer < AMQP::Boilerplate::Consumer
  amqp_queue "queue.name.here", :durable => true
  amqp_subscription :ack => true
end

class FooConsumer < AMQP::Boilerplate::Consumer
  amqp_queue
end

describe AMQP::Boilerplate::Consumer do
  before(:each) do
    @channel = mock(AMQP::Channel)
    @channel.stub(:on_error).and_return(true)
  end

  describe "#handle_channel_error" do
    before(:each) do
      @channel_close = mock(:reply_code => "OK", :reply_text => "Something")
    end

    it "should log the code and message" do
      AMQP::Boilerplate.logger.should_receive(:error).with("[DummyConsumer#handle_channel_error] Code = #{@channel_close.reply_code}, message = #{@channel_close.reply_text}")

      DummyConsumer.new.handle_channel_error(@channel, @channel_close)
    end
  end

  describe "#handle_message" do
    it "should raise an error (must be implemented by subclasses)" do
      expect {
        AMQP::Boilerplate::Consumer.new.handle_message(anything, anything)
      }.to raise_error(NotImplementedError, "The time has come to implement your own consumer class. Good luck!")
    end
  end

  describe ".amqp_queue" do
    before(:each) do
      AMQP.stub(:channel).and_return(@channel)
      @queue = mock(AMQP::Queue)
      @channel.stub(:queue).and_return(@queue)
      @queue.stub(:subscribe)
    end

    it "should use a default name for queue" do
      @channel.should_receive(:queue).with(AMQ::Protocol::EMPTY_STRING, anything).and_return(@queue)

      FooConsumer.start
    end

    it "should use a empty hash for queue options" do
      @channel.should_receive(:queue).with(anything, {}).and_return(@queue)

      FooConsumer.start
    end
  end

  describe ".start" do
    before(:each) do
      @consumer = DummyConsumer.new
      DummyConsumer.stub(:new).and_return(@consumer)

      AMQP.stub(:channel).and_return(@channel)

      @queue = mock(AMQP::Queue)
      @channel.stub(:queue).and_return(@queue)
      @queue.stub(:subscribe)
    end

    it "should use a channel" do
      AMQP.should_receive(:channel).and_return(@channel)
      DummyConsumer.start
    end

    it "should instantiate a consumer" do
      DummyConsumer.should_receive(:new).and_return(@consumer)
      DummyConsumer.start
    end

    it "should register a channel error handler" do
      @channel.should_receive(:on_error)
      DummyConsumer.start
    end

    it "should instantiate a queue with the proper queue name" do
      @channel.should_receive(:queue).with("queue.name.here", anything)
      DummyConsumer.start
    end

    it "should instantiate a queue provided with options" do
      @channel.should_receive(:queue).with(anything, :durable => true)
      DummyConsumer.start
    end

    it "should subscribe to the queue" do
      @queue.should_receive(:subscribe).with(:ack => true)
      DummyConsumer.start
    end
  end
end
