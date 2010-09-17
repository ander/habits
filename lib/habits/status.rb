require 'date'
require 'time'

module Habits
  class Status
    include Comparable
    
    VALUES = [:green, :yellow, :red, :missed, :on_hold]
    VALUES.each do |val|
      eval %Q(def self.#{val}; Status.new(#{val.inspect}) end)
    end
    
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
      
      habit.days.each do |day|
        activities = habit.activities_on_week(today.cweek, day)
        
        if activities.empty?
          day_diff = Time::RFC2822_DAY_NAME.index(day) - today.wday
          deadline = Time.mktime(today.year, today.month, 
                                 today.day + day_diff, 23, 59)
          
          if time > deadline
            statuses << Status.missed
          elsif time > (deadline - habit.red_zone)
            statuses << Status.red
          elsif time > (deadline - habit.yellow_zone)
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