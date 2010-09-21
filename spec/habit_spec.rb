require 'habits/habit'

describe Habits::Habit do
  
  it "should set title when created" do
    h = Habits::Habit.new('test_title')
    h.title.should == 'test_title'
  end

  it "should raise if space in title" do
    lambda { Habits::Habit.new('test test')}.should raise_error
  end

  it "should raise if comma in title" do
    lambda { Habits::Habit.new('test,test')}.should raise_error
  end

end
