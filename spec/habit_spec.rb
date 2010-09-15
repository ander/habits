require 'habits/habit'

describe Habits::Habit do
  it "should set title when created" do
    h = Habits::Habit.new('test title')
    h.title.should == 'test title'
  end
  
  it "should set valid statuses" do
    h = Habits::Habit.new('habit one')
    h.status.should == :green
    h.set_status(:yellow)
    h.status.should == :yellow
    h.set_status(:green)
    h.status.should == :green
    h.set_status(:red)
    h.status.should == :red
    h.set_status(:black)
    h.status.should == :black
  end
  
  it "should raise if trying to set invalid status" do
    h = Habits::Habit.new('habit one')
    lambda {h.set_status(:foobar)}.should raise_error('Invalid status')
  end
  
end
