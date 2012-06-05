require 'spec_helper'

describe AMQP::Boilerplate do
  describe ".boot" do
    before(:each) do
      AMQP::Boilerplate.stub(:logger).and_return(mock.as_null_object)

      EventMachine.stub(:next_tick).and_yield
      AMQP::Utilities::EventLoopHelper.stub(:run).and_yield

      AMQP.stub(:connection).and_return(mock(AMQP::Session))
      AMQP::Channel.stub(:new).and_return(mock(AMQP::Channel))

      AMQP::Boilerplate.stub(:load_consumers)
      AMQP::Boilerplate.stub(:start_consumers)
      AMQP::Boilerplate.stub(:start)
      AMQP::Boilerplate.stub(:sleep)
    end

    it "should load all consumers" do
      AMQP::Boilerplate.should_receive(:load_consumers)
      AMQP::Boilerplate.boot
    end

    it "should connect to AMQP" do
      AMQP::Boilerplate.should_receive(:start)
      AMQP::Boilerplate.boot
    end

    it "should sleep for a while" do
      AMQP::Boilerplate.should_receive(:sleep).with(0.25)
      AMQP::Boilerplate.boot
    end

    describe "when server type is unknown" do
      before(:each) do
        AMQP::Boilerplate.force_consumers = false
        AMQP::Utilities::EventLoopHelper.stub(:server_type).and_return(nil)
      end

      it "should not start consumers" do
        AMQP::Boilerplate.should_not_receive(:start_consumers)
        AMQP::Boilerplate.boot
      end

      it "should start consumers if forced" do
        AMQP::Boilerplate.force_consumers = true
        AMQP::Boilerplate.should_receive(:start_consumers)
        AMQP::Boilerplate.boot
      end

      it "should log server type as 'unknown'" do
        AMQP::Boilerplate.logger.should_receive(:info).with(/Server Type: unknown/)
        AMQP::Boilerplate.boot
      end

      it "should log that consumers are not loaded" do
        AMQP::Boilerplate.logger.should_receive(:debug).with(/Unknown server type, not starting consumers/)
        AMQP::Boilerplate.boot
      end
    end

    describe "wen not using passenger" do
      before(:each) do
        AMQP::Utilities::EventLoopHelper.stub(:server_type).and_return(:mongrel)
      end

      it "should use built-in EventLoopHelper" do
        AMQP::Utilities::EventLoopHelper.should_receive(:run)
        AMQP::Boilerplate.boot
      end

      it "should start all consumers" do
        AMQP::Boilerplate.should_receive(:start_consumers)
        AMQP::Boilerplate.boot
      end
    end

    describe "when using passenger" do
      before(:each) do
        AMQP::Utilities::EventLoopHelper.stub(:server_type).and_return(:passenger)

        PhusionPassenger = Class.new
        PhusionPassenger.stub(:on_event).and_yield(true)

        @thread = mock(Thread)
        Thread.stub(:new).and_yield.and_return(@thread)
      end

      # Don't try this at home!
      after(:each) do
        Object.send(:remove_const, "PhusionPassenger")
      end

      it "should start all consumers" do
        AMQP::Boilerplate.should_receive(:start_consumers)
        AMQP::Boilerplate.boot
      end

      it "should register to starting_worker_process event" do
        PhusionPassenger.should_receive(:on_event).with(:starting_worker_process)
        AMQP::Boilerplate.boot
      end

      it "should start new thread after process forked" do
        Thread.should_receive(:new)
        AMQP::Boilerplate.boot
      end
    end
  end

  describe ".shutdown" do
    subject { described_class.shutdown }

    before do
      EventMachine::Timer.stub(:new).and_yield
      EventMachine.stub(:stop)
    end

    it "closes AMQP connection" do
      AMQP.should_receive(:stop)
      subject
    end

    it "stops EventMachine" do
      EventMachine.should_receive(:stop)
      subject
    end

    it "sets a one-off timer to make sure event loop shuts down" do
      EventMachine::Timer.should_receive(:new)
      subject
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

    it "should allow us to set a prefetch value" do
      prefetch = 10
      AMQP::Boilerplate.configure { |config| config.consumer_prefetch = prefetch }
      AMQP::Boilerplate.consumer_prefetch.should == prefetch
    end

    it "should let us set a handler for uncaught exceptions" do
      on_unhandled_consumer_exception = Proc.new {}
      AMQP::Boilerplate.configure { |config| config.on_unhandled_consumer_exception = on_unhandled_consumer_exception }
      AMQP::Boilerplate.on_unhandled_consumer_exception.should == on_unhandled_consumer_exception
    end
  end

  describe ".start" do
    before(:each) do
      AMQP.stub(:start)
    end

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
