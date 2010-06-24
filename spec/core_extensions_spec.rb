require 'spec_helper'

class MyObject
  include Rose::CoreExtensions
end

describe "CoreExtensions" do
  before do
    @o = MyObject.new
  end

  describe "#require_keys" do
    it "should raise exception if missing required key" do
      lambda {
        @o.require_keys({:name => 'foo'}, :value)
      }.should raise_error(ArgumentError, "Missing required key(s): value")
    end

    it "should not raise exception if not missing required key" do
      lambda {
        @o.require_keys({:name => 'foo', :value => 'bar'}, :value)
      }.should_not raise_error
    end

    it "should raise exception if missing required keys" do
      lambda {
        @o.require_keys({}, :name, :value)
      }.should raise_error(ArgumentError, "Missing required key(s): name, value")
    end

    it "should not raise exception if not missing required keys" do
      lambda {
        @o.require_keys({:name => 'foo', :value => 'bar'}, :name, :value)
      }.should_not raise_error
    end
  end

  describe "#required_values" do
    it "should return values of required keys" do
      @o.expects(:require_keys).with({:name => 'foo', :value => 'bar'}, :name, :value)
      foo, bar = @o.required_values({:name => 'foo', :value => 'bar'}, :name, :value)
      foo.should == 'foo'
      bar.should == 'bar'
    end

    it "should return value of required key" do
      @o.expects(:require_keys).with({:name => 'foo', :value => 'bar'}, :name)
      foo = @o.required_values({:name => 'foo', :value => 'bar'}, :name)
      foo.should == 'foo'
    end
  end
end