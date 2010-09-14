require 'habits/event'

module Habits
  
  class ToggleOnHold
    include Event
    
    def apply(habit)
      super
      habit.on_hold = !habit.on_hold
    end
  end
  
end