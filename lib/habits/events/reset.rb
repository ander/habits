require 'habits/event'

module Habits::Events

  class Reset
    include Habits::Event
    
    def initialize
    end
    
    def apply(habit)
      super
    end
    
  end
  
end