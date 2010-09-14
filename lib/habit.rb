=begin rdoc

The habit class. 

=end
class Habit
  
  def initialize(title)
    @title = title
    @on_hold = false
    @estimated_duration = nil
    @repeat_policy = nil
    @events = []
  end
  
  def total_time_elapsed
    # count time from events
  end
  
end