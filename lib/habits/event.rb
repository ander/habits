module Habits
  
  module Event
    attr_reader :applied_at
  
    def apply(habit, time=Time.now)
      @applied_at = time
    end
  end
  
end