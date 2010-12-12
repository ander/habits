require 'habits/habit'
require 'habits/mock_data_store'

describe Habits::Status do
  def last_day(wday, hour, minutes) # in wday, 0 = sunday, 1 = monday...
    today = Date.today
    day_diff = wday - today.wday
    Time.mktime(today.year, today.month, today.day + day_diff, hour, minutes)
  end
  
  it "should resolve status green" do
    h = Habits::Habit.new('test', ['Mon'])  
    Habits::Status.resolve(h, last_day(1,0,0)).should == Habits::Status.green
  end
  
  it "should resolve status yellow" do
    h = Habits::Habit.new('test', ['Mon'])  
    
    Habits::Status.resolve(h, last_day(1,8,0)).should == Habits::Status.yellow
    Habits::Status.resolve(h, last_day(1,17,59)).should == Habits::Status.yellow
  end
  
  it "should resolve status red" do
    h = Habits::Habit.new('test', ['Mon'])
    
    Habits::Status.resolve(h, last_day(1,18,0)).should == Habits::Status.red
    Habits::Status.resolve(h, last_day(1,23,59)).should == Habits::Status.red
  end
  
  it "should resolve status missed" do
    h = Habits::Habit.new('test', ['Mon'])  
    
    Habits::Status.resolve(h, last_day(2,0,0)).should == Habits::Status.missed
  end
  
  it "should resolve status for a two day habit" do
    h = Habits::Habit.new('test', ['Mon', 'Tue'])
    e = Habits::Events::Activity.new
    h.add_event(e, last_day(1, 20, 00))
    Habits::Status.resolve(h, last_day(2,23,59)).should == Habits::Status.red
  end
  
  it "should resolve status for a two day habit (2)" do
    h = Habits::Habit.new('test', ['Mon', 'Tue'])
    e = Habits::Events::Activity.new
    h.add_event(e, last_day(2, 20, 00))
    Habits::Status.resolve(h, last_day(2,23,59)).should == Habits::Status.missed
  end
  
  it "should resolve status for a three day habit" do
    h = Habits::Habit.new('test', ['Mon', 'Thu', 'Sun'])
    e = Habits::Events::Activity.new
    h.add_event(e, last_day(4, 20, 00))
    Habits::Status.resolve(h, last_day(0,12,00)).should == Habits::Status.missed
  end
  
end
