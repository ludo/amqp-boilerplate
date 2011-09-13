require 'spec_helper'

describe AMQP::Boilerplate do
  describe ".boot" do
    before(:each) do
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
  end
end
