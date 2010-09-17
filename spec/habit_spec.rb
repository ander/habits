require 'habits/habit'

describe Habits::Habit do
  
  it "should set title when created" do
    h = Habits::Habit.new('test title')
    h.title.should == 'test title'
  end

end
