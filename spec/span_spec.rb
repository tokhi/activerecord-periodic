require 'spec_helper'

include ActiveRecordPeriodic

describe Span do
  before(:each) do
    @now = Time.now
  end

  it "gets initialized through a start and end or throuh text" do
    a = @now - 1.day
    b = @now

    span = Span[a, b]
    span.beginning.should == a
    span.end.should == b

    span = Span['today']
    span.beginning.should == @now.beginning_of_day
    span.end.should == @now.end_of_day
  end

  it "knows how long it is" do
    Span[@now.yesterday, @now].length.should == 1.day + 1
  end

  it "has a valid String representation" do
    a = Span['today']
    b = Span[a.to_s]
    b.should === a
  end

  it "has a valid Array representation" do
    a = Span['today']
    b = Span[a.to_a]
    b.should === a
  end

  it "#== compares by length and #=== is stricter" do
    Span['today'].should == Span['yesterday']
    Span['today'].should_not === Span['yesterday']
  end

  it "#per should yield span breakdown per aggregate" do
    Span['this week'].per(:day) do |day|
      day.kind_of?(Span).should be_true
      day.length.should == 1.day
    end.should == 7
  end

  it "#days, etc. should shortcut per(:day) with no block" do
    period = 'last week'
    Span[period].per(:day).should == Span[period].days
  end

  it "#per should return an array if no block given" do
    days = Span['this week'].per(:day)
    days.map(&:class).uniq.should == [ Span ]
    days.size.should == 7
  end

  it "#disjoint? tells if two spans have no overlap" do
    Span['today'].disjoint?(Span['yesterday']).should be_true
    Span['today'].disjoint?(Span['this week']).should_not be_true
  end
end

