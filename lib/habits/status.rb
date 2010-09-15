
module Habits
  class Status
    include Comparable
    
    VALUES = [:green, :yellow, :red, :black]
    
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
  end
end