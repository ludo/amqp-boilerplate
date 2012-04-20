require 'spec_helper'

describe AMQP::Boilerplate::ForceConsumers do
  before(:each) do
    AMQP::Boilerplate.stub(:logger).and_return(mock.as_null_object)
    @channel = mock(AMQP::Channel)
    @channel.stub(:on_error).and_return(true)
  end

  describe "#force_consumers" do
    before(:each) do
      @channel_close = mock(:reply_code => "OK", :reply_text => "Something")
    end

    it "should be false by default" do
      AMQP::Boilerplate.force_consumers.should be_an(FalseClass)
    end
  end
end
