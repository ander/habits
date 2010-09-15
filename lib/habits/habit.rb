require 'fileutils'
require 'yaml'

require 'habits/status'

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
    
    attr_reader :title, :times, :days, :status
    
    def initialize(title, times=1, days=['Mon'])
      raise "Too many days" if days.size > times
      @title = title
      @times = times
      @days = days
      @status = Status.green
      @on_hold = false
      @created_at = Time.now
      @events = []
    end
    
    def parts
      parts = []
      days = @days.clone.reverse
      @times.times do |i|
        parts << Habit.new("#{@title} part #{i+1}", 1, [days.pop].compact)
      end
      parts
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
      @status = parts.map{|part| Status.resolve(part)}.max
      save
    end
    
    def last_reset
      reset_event = @events.reverse.detect{|e| e.is_a?(Habits::Events::Reset)}
      reset_event ? reset_event.applied_at : @created_at
    end
    
  end
  
end