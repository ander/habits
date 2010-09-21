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

  it "should split itself" do
    h = Habits::Habit.new('test_title', ['Mon', 'Tue'])
    h2, h3 = h.split
    h2.days.should == ['Mon']
    h3.days.should == ['Tue']
    h2.title.should == 'test_title:Mon'
    h3.title.should == 'test_title:Tue'
  end

end
