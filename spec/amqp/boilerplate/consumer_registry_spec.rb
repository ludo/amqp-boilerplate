require 'spec_helper'

describe AMQP::Boilerplate::ConsumerRegistry do
  before(:each) do
    AMQP::Boilerplate.stub(:logger).and_return(mock.as_null_object)
  end

  describe "#consumer_paths" do
    it "should be an Array" do
      AMQP::Boilerplate.consumer_paths.should be_an(Array)
    end

    it "should always return the same Array" do
      consumer_paths = AMQP::Boilerplate.consumer_paths
      AMQP::Boilerplate.consumer_paths.should equal(consumer_paths)
    end

    it "should default to an empty Array" do
      AMQP::Boilerplate.consumer_paths.should be_empty
    end
  end

  describe "#load_consumers" do
    before(:each) do
      AMQP::Boilerplate.stub(:registry).and_return([])
    end

    it "should require all files in configured consumer_paths" do
      AMQP::Boilerplate.consumer_paths << File.expand_path(File.join(File.dirname(__FILE__), '..', '..', "fixtures/consumers"))

      defined?(DummyConsumer).should be_nil
      AMQP::Boilerplate.load_consumers
      defined?(DummyConsumer).should_not be_nil
    end
  end

  describe "#register_consumer" do
    before(:each) do
      AMQP::Boilerplate.stub(:registry).and_return(Array.new)
    end

    it "should call #registry" do
      AMQP::Boilerplate.should_receive(:registry).once
      AMQP::Boilerplate.register_consumer(mock.as_null_object)
    end

    it "should add classes to registry" do
      expect {
        AMQP::Boilerplate.register_consumer(mock.as_null_object)
      }.to change(AMQP::Boilerplate.registry, :size).by(1)
    end
  end

  describe "#registry" do
    it "should return an Array" do
      AMQP::Boilerplate.registry.should be_an(Array)
    end

    it "should always return the same array" do
      registry = AMQP::Boilerplate.registry
      AMQP::Boilerplate.registry.should equal(registry)
    end
  end

  describe "#start_consumers" do
    it "should call .start on all registered consumer classes" do
      FooConsumer.should_receive(:start)
      BarConsumer.should_receive(:start)
      AMQP::Boilerplate.start_consumers
    end
  end
end
