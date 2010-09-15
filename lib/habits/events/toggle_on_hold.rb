require 'habits/event'

module Habits::Events
  
  class ToggleOnHold
    include Habits::Event
    
    def apply(habit)
      super
      habit.on_hold = !habit.on_hold
    end
  end
  
end