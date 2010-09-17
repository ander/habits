require 'date'

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
    
    # Resolves the status of a habit.
    # Status starts fresh every week.
    def self.resolve(habit)
      statuses = []
      today = Date.today
      
      habit.days.each do |day|
        activities = habit.activities_on_week(today.cweek, day)
        
        if activities.empty?
          deadline = Time.mktime(today.year, today.month, today.day, 23, 59)
          
          if Time.now > (deadline - RED_ZONE)
            statuses << Status.red
          elsif Time.now > (deadline - YELLOW_ZONE)
            statuses << Status.yellow
          else
            statuses << Status.green
          end
        else
          statuses << Status.green
        end
      end
      statuses.max
    end
    
  end
end