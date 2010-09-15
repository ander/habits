require 'habits/event'

module Habits::Events

  class Activity
    include Habits::Event
    
    def initialize(duration=nil)
      @duration = duration
    end
  
    def apply(habit)
      super
    end
    
  end
  
end