require 'spec_helper'

describe AMQP::Boilerplate do
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
