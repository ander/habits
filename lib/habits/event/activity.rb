require 'habits/event'

module Habits

  class Activity
    include Event
    
    def initialize(duration=nil)
      @duration = duration
    end
  
    def apply(habit)
      super
    end
    
  end
  
end