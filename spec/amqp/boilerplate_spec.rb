require 'spec_helper'

describe AMQP::Boilerplate do
  describe ".boot" do
    before(:each) do
      AMQP::Boilerplate.stub(:logger).and_return(mock.as_null_object)

      EventMachine.stub(:next_tick).and_yield

      AMQP::Boilerplate.stub(:start_consumers)
      AMQP::Boilerplate.stub(:load_consumers)
    end

    it "should load all consumers" do
      AMQP::Boilerplate.should_receive(:load_consumers)
      AMQP::Boilerplate.boot
    end

    it "should start all consumers" do
      AMQP::Boilerplate.should_receive(:start_consumers)
      AMQP::Boilerplate.boot
    end
  end

  describe ".configure" do
    after(:each) do
      AMQP::Boilerplate.logger = nil
    end

    it "should let us choose what logger to use" do
      MyFunkyLogger = Class.new
      AMQP::Boilerplate.configure { |config| config.logger = MyFunkyLogger }
      AMQP::Boilerplate.logger.should == MyFunkyLogger
    end

    it "should let us choose where consumers can be found" do
      consumer_path = 'app/consumers'
      AMQP::Boilerplate.configure { |config| config.consumer_paths << consumer_path }
      AMQP::Boilerplate.consumer_paths.should include(consumer_path)
    end

    it "should allow us to set connection options" do
      connection_options = { :host => "localhost", :port => 5672 }
      AMQP::Boilerplate.configure { |config| config.connection_options = connection_options }
      AMQP::Boilerplate.connection_options.should == connection_options
    end
  end

  describe ".start" do
    it "should start AMQP" do
      AMQP.should_receive(:start)
      AMQP::Boilerplate.start
    end

    it "should use the connection options" do
      AMQP::Boilerplate.connection_options = { :host => "localhost", :port => 5672 }
      AMQP.should_receive(:start).with(AMQP::Boilerplate.connection_options)
      AMQP::Boilerplate.start
    end
  end
end
