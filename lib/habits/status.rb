
module Habits
  class Status
    include Comparable
    
    VALUES = [:green, :yellow, :red, :black]
    VALUES.each do |val|
      eval %Q(def self.#{val}; Status.new(#{val.inspect}) end)
    end
    
    YELLOW_ZONE = 24*60*60 # 24 hours before deadline
    RED_ZONE = 6*60*60     #  6 -"-
    
    attr_reader :value
    
    def initialize(val)
      raise "Invalid status value" unless VALUES.include?(val)
      @value = val
    end
    
    def <=>(other)
      VALUES.index(self.value) <=> VALUES.index(other.value)
    end
    
    # Resolves the status of a (simple) habit.
    # Status starts fresh every week.
    def self.resolve(habit)
      raise "Cannot resolve status" if habit.days.size > 1 or habit.times != 1
      
      # ...
      Status.red
    end
    
  end
end