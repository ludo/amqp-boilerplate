require 'spec_helper'

describe AMQP::Boilerplate::ConsumerPrefetch do
  before(:each) do
    AMQP::Boilerplate.stub(:logger).and_return(mock.as_null_object)
    @channel = mock(AMQP::Channel)
    @channel.stub(:on_error).and_return(true)
  end

  describe "#consumer_prefetch" do
    before(:each) do
      @channel_close = mock(:reply_code => "OK", :reply_text => "Something")
    end

    it "should be 0 by default" do
      AMQP::Boilerplate.consumer_prefetch.should == 0
    end
  end
end
