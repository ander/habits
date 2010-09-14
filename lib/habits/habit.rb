
module Habits

  # The habit class. Attached events describe activities etc.
  class Habit
    attr_accessor :on_hold
  
    def initialize(title)
      @title = title
      @description = ''
      @on_hold = false
      @repeat_policy = nil
      @events = []
    end
  
    def add_event(event)
      event.apply(self)
      @events << event
      event
    end
    
    def total_time_elapsed
      # count time from events
    end
  end
  
end