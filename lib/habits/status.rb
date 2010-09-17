require 'date'

module Habits
  class Status
    include Comparable
    
    VALUES = [:green, :yellow, :red, :black]
    VALUES.each do |val|
      eval %Q(def self.#{val}; Status.new(#{val.inspect}) end)
    end
    
    YELLOW_ZONE = 20*60*60 # 24 hours before deadline
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
    def self.resolve(habit, time=Time.now)
      statuses = []
      today = Date.today
      days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
      
      habit.days.each do |day|
        activities = habit.activities_on_week(today.cweek, day)
        
        if activities.empty?
          day_diff = days.index(day) - today.wday
          deadline = Time.mktime(today.year, today.month, 
                                 today.day + day_diff, 23, 59)
          
          if time > deadline
            statuses << Status.black
          elsif time > (deadline - RED_ZONE)
            statuses << Status.red
          elsif time > (deadline - YELLOW_ZONE)
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