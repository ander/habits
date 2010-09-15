
module Habits
  class Status
    include Comparable
    VALUES = [:green, :yellow, :red, :black]
    
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
    
    def self.green; Status.new(:green) end
    def self.yellow; Status.new(:yellow) end
    def self.red; Status.new(:red) end
    def self.black; Status.new(:black) end
    
    def self.resolve(habit)
      raise "Cannot resolve status" if habit.days.size > 1 or habit.times != 1
      
      start = habit.last_reset
      # ....
    end
    
  end
end