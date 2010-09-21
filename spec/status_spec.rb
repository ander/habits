require 'habits/habit'


describe Habits::Status do
  def last_day(wday, hour, minutes) # in wday, 0 = sunday, 1 = monday...
    today = Date.today
    day_diff = wday - today.wday
    Time.mktime(today.year, today.month, today.day + day_diff, hour, minutes)
  end
  
  it "should resolve status green" do
    h = Habits::Habit.new(['Mon'])  
    Habits::Status.resolve(h, last_day(1,0,0)).should == Habits::Status.green
  end
  
  it "should resolve status yellow" do
    h = Habits::Habit.new(['Mon'])  
    
    Habits::Status.resolve(h, last_day(1,8,0)).should == Habits::Status.yellow
    Habits::Status.resolve(h, last_day(1,17,59)).should == Habits::Status.yellow
  end
  
  it "should resolve status red" do
    h = Habits::Habit.new(['Mon'])
    
    Habits::Status.resolve(h, last_day(1,18,0)).should == Habits::Status.red
    Habits::Status.resolve(h, last_day(1,23,59)).should == Habits::Status.red
  end
  
  it "should resolve status missed" do
    h = Habits::Habit.new(['Mon'])  
    
    Habits::Status.resolve(h, last_day(2,0,0)).should == Habits::Status.missed
  end
  
end
