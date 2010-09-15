require 'habits/habit'

module Habits
  
  module Whip
    extend self
    
    def on(status, &blk)
      @@transitions ||= {}
      @@transitions[status] = blk
    end
    
    def check
      Habit.all.each do |habit|
        habit.update_status do
          st = habit.status.value
          @@transitions[st].call(habit) if @@transitions[st]
        end
      end
    end
  end
end

config = File.join(Habits::Habit::HABITS_DIR, 'whip_config.rb')
require config if File.exists?(config)
