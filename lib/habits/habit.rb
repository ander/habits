require 'fileutils'
require 'yaml'

require 'habits/status'
require 'habits/events/activity'

module Habits

  # The habit class. Attached events describe activities etc.
  class Habit
    HABITS_DIR  = File.join(ENV['HOME'], '.habits')
    YELLOW_ZONE = 16*60*60 # 16 hours before deadline,
    RED_ZONE    = 6*60*60  #  6 -"-
    
    def self.all
      @@all ||= begin
        habits = []
        Dir.glob(File.join(HABITS_DIR, '*.habit')).each do |habit_file|
          habits << YAML.load(File.read(habit_file))
        end
        habits
      end
    end
    
    def self.find(title)
      h = Habit.all.detect {|h| h.title == title.strip}
      raise "No such habit found." unless h
      h
    end
    
    # Join all habits with title 'title':something.
    def self.join_all(title)
      joinables = Habit.all.select {|habit| habit.title =~ /^#{title}:.+/}
      raise "Habits not found." if joinables.size == 0
      habit = Habit.find(title) rescue nil
      habit ||= Habit.new(title, [])
      joinables.each{|joinable| habit.join!(joinable)}
    end
    
    attr_reader :title, :days, :status, :events
    attr_accessor :yellow_zone, :red_zone
    
    def initialize(title, days = ['Mon'], 
                   yellow_zone = YELLOW_ZONE, 
                   red_zone    = RED_ZONE,
                   events      = [])
      set_title(title)
      set_days(days)
      @yellow_zone, @red_zone = yellow_zone, red_zone
      @status = Status.green
      @created_at = Time.now
      @events = events
    end
    
    def add_event(event, time=Time.now)
      event.apply(self, time)
      @events << event
      save
    end
    
    def file_path(title=@title)
      File.join(HABITS_DIR, title.downcase + '.habit')
    end
    
    def save
      @@all = nil
      FileUtils.rm_f(file_path(@old_title)) if @old_title
      FileUtils.mkdir_p HABITS_DIR
      File.open(file_path, 'w') do |file|
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
      FileUtils.rm_f file_path
      @@all = nil
    end
    
    def set_title(title)
      raise "No spaces or commas allowed in habit title" if title =~ /[\s,,]+/
      @old_title = @title
      @title = title
    end
    
    def set_days(days)
      if days.detect{|d| Time::RFC2822_DAY_NAME.index(d).nil?}
        raise "Valid days are #{Time::RFC2822_DAY_NAME.join(',')}"
      else
        @days = days
      end
    end
    
    def split
      @days.map do |day|
        events = @events.select{|event| event.applied_at.strftime('%a') == day}
        Habit.new("#{@title}:#{day}", [day], YELLOW_ZONE, RED_ZONE, events)
      end
    end
    
    def split!
      habits = split
      habits.each{|habit| habit.save}
      destroy
      habits
    end
    
    def join(habit)
      @events += habit.events
      @days += habit.days
      @days.uniq!
      @days.sort!{|a,b| Time::RFC2822_DAY_NAME.index(a) <=> Time::RFC2822_DAY_NAME.index(b)}
    end
    
    def join!(habit)
      join(habit)
      save
      habit.destroy
    end
    
  end
  
end