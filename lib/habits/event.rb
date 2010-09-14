module Habits
  
  module Event
    attr_reader :applied_at
  
    def apply(habit)
      puts "APPLIED"
      @applied_at = Time.now
    end
  end
  
end