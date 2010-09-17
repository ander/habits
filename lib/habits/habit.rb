require 'fileutils'
require 'yaml'

require 'habits/status'
require 'habits/events/activity'

module Habits

  # The habit class. Attached events describe activities etc.
  class Habit
    HABITS_DIR = File.join(ENV['HOME'], '.habits')
    
    def self.all
      @@all ||= begin
        habits = []
        Dir.glob(File.join(HABITS_DIR, '*.habit')).each do |habit_file|
          habits << YAML.load(File.read(habit_file))
        end
        habits
      end
    end
    
    attr_reader :title, :days, :status
    attr_accessor :yellow_zone, :red_zone
    
    def initialize(title, days=['Mon'], 
                   yellow_zone=20*60*60, # 24 hours before deadline,
                   red_zone=6*60*60      #  6 -"-
                   )
      @title, @days, @yellow_zone, @red_zone = title, days, yellow_zone, red_zone
      @status = Status.green
      @created_at = Time.now
      @events = []
    end
    
    def add_event(event)
      event.apply(self)
      @events << event
      save
    end
    
    def filename
      @title.downcase.gsub(' ', '_') + '.habit'
    end
    
    def save
      @@all = nil
      FileUtils.mkdir_p HABITS_DIR
      File.open(File.join(HABITS_DIR, filename), 'w') do |file|
        file.write self.to_yaml
      end
      self
    end
    
    def update_status
      old_status = @status
      @status = Status.resolve(self)
      
      if old_status != @status
        yield if block_given?
        save
      end
    end
    
    def activities_on_week(week, day=nil)
      activities = @events.select do |e| 
        e.is_a?(Events::Activity) and Date.new(e.applied_at.year, 
                                               e.applied_at.month,
                                               e.applied_at.day).cweek == week
      end
      activities = activities.select{|a| a.applied_at.strftime('%a') == day} if day
      activities
    end
    
    def destroy
      FileUtils.rm_f File.join(HABITS_DIR, filename)
      @@all = nil
    end
    
  end
  
end