require 'spec_helper'

describe AMQP::Boilerplate::Logging do
  after(:each) do
    # Reset
    AMQP::Boilerplate.logger = nil
  end

  describe "#logger" do
    it "should set the logger to use" do
      MyLogger = Class.new
      AMQP::Boilerplate.logger = MyLogger # { |config| config.logger = MyLogger }
      AMQP::Boilerplate.logger.should == MyLogger
    end

    it "should default to Ruby Logger" do
      AMQP::Boilerplate.logger.should be_a(Logger)
    end

    it "should default to Logger writing to STDOUT" do
      Logger.should_receive(:new).with(STDOUT)
      AMQP::Boilerplate.logger
    end
  end
end
