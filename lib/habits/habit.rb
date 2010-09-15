require 'fileutils'
require 'yaml'

module Habits

  # The habit class. Attached events describe activities etc.
  class Habit
    STATUSES = [:green, :yellow, :red, :black]
    HABITS_DIR = File.join(ENV['HOME'], '.habits')
    
    attr_reader :status, :title
    
    def initialize(title, times=1, days=['Mon'])
      @title = title
      @times_per_week = times
      @days = days
      @status = :green
      @on_hold = false
      @created_at = Time.now
      @events = []
    end
    
    def self.all
      habits = []
      Dir.glob(File.join(HABITS_DIR, '*.habit')).each do |habit_file|
        habits << YAML.load(File.read(habit_file))
      end
      habits
    end
    
    def set_status(new_status)
      raise "Invalid status" unless STATUSES.include?(new_status)
      @status = new_status
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
      FileUtils.mkdir_p HABITS_DIR
      File.open(File.join(HABITS_DIR, filename), 'w') do |file|
        file.write self.to_yaml
      end
      self
    end
    
  end
  
end