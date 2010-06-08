require 'spec_helper'

describe Rose do
  context "make report" do
    before do
      @called = called = false
      @blk = lambda { called = true }
    end

    it "should make new report with object adapter" do
      Rose::Seedling.expects(:new).with(Rose::ObjectAdapter, {}).returns(instance = mock('Instance'))
      Rose.make(:test, &@blk).should == instance
    end

    it "should make new report with options" do
      Rose::Seedling.expects(:new).with(Rose::ObjectAdapter, {:class => Fixnum}).returns(instance = mock('Instance'))
      Rose.make(:test, :class => Fixnum, &@blk).should == instance
    end

    it "should make new report with block" do
      Rose::Seedling.expects(:new).with(Rose::ObjectAdapter, {:class => Fixnum}).returns(instance = mock('Instance'))

      scope = nil
      Rose.make(:test, :class => Fixnum) do
        scope = self
      end
      scope.should == instance
    end
  end

  it "should not contain code smells" do
    Dir['lib/**/*.rb'].should_not reek
  end
end
