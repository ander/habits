require 'habits/event'

module Habits::Events

  class Activity
    include Habits::Event
    
    attr_reader :duration
    
    def initialize(duration=nil)
      @duration = duration
    end
  
    def apply(habit, time)
      super
    end
    
  end
  
end