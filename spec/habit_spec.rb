require 'habits/habit'

describe Habits::Habit do
  it "should set title when created" do
    h = Habits::Habit.new('test title')
    h.title.should == 'test title'
  end
  
  it "should divide itself into parts (1)" do
    h = Habits::Habit.new('habit one', 1, [])
    parts = h.parts
    parts.size.should == 1
    parts.first.times.should == 1
    parts.first.days.should be_empty
  end
  
  it "should divide itself into parts (2)" do
    h = Habits::Habit.new('habit one', 2, [])
    parts = h.parts
    parts.size.should == 2
    parts[0].days.should be_empty
    parts[1].days.should be_empty
  end
  
  it "should divide itself into parts (3)" do
    h = Habits::Habit.new('habit one', 2, ['Mon', 'Fri'])
    parts = h.parts
    parts.size.should == 2
    parts[0].days.should == ['Mon']
    parts[1].days.should == ['Fri']
  end
  
  it "should divide itself into parts (4)" do
    h = Habits::Habit.new('habit one', 3, ['Thu', 'Fri'])
    parts = h.parts
    parts.size.should == 3
    parts[0].days.should == ['Thu']
    parts[1].days.should == ['Fri']
    parts[2].days.should be_empty
  end
  
end
