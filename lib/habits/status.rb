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
      return Status.on_hold if habit.status == Status.on_hold
      
      statuses = []
      date = Date.new(time.year, time.month, time.day)
      
      habit.days.each do |day|
        activities = habit.activities_on_week(date.cweek, day)
        day_diff = Habit::DAYS.index(day) - date.wday
        day_diff -= 7 if day_diff > 0
        
        if !activities.empty?
          statuses << Status.green
        else
          dl_date = date + day_diff
          deadline = Time.mktime(dl_date.year, dl_date.month, 
                                 dl_date.day, 23, 59)
          
          if time > deadline
            statuses << Status.missed
          elsif time > (deadline - habit.red_zone)
            statuses << Status.red
          elsif time > (deadline - habit.yellow_zone)
            statuses << Status.yellow
          else
            statuses << Status.green
          end
        end
      end
      statuses.max
    end
    
  end
end