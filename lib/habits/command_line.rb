require 'time'
require 'optparse'
require 'habits'

module Habits
  
  class CommandLine
    
    def initialize(args)
      @args = args
    end
    
    def parse
      opts = OptionParser.new
      
      opts.on("-w", "Use the whip.") do
        Whip.use
      end
      
      opts.on("-d TITLE", "Delete habit.") do |title|
        h = Habit.all.detect{|h| h.title == title.strip}
        if h
          h.destroy
          puts "#{h.title} deleted."
        else
          puts "No such habit found."
        end
      end
      
      opts.on("-a TITLE DAYS", "Add a new habit.", String) do |params|
        words = params.strip.split
        days = words.pop.split(',')
        title = words.join(' ')
        
        if days.detect{|d| Time::RFC2822_DAY_NAME.index(d).nil?}
          puts "Valid days are #{Time::RFC2822_DAY_NAME.join(',')}"
        else
          Habit.new(title, days).save
          puts "Habit \"#{title}\" added."
        end
      end
      
      opts.on("-l", "List habits.") do
        puts "HABITS (days, status)\n======\n"
        Habit.all.each do |habit|
          printf("%-40s %-30s %s\n", habit.title, habit.days.join(','),
                                     habit.status.value.to_s.capitalize)
        end
        puts "======\nTotal #{Habit.all.size} habits."
      end
      
      opts.on_tail("-h", "--help", "Display help.") do
        puts opts
      end
      
      opts.parse!(@args)
      
      # without options is the same as list..
    end
  end
  
end