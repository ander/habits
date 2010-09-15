require 'habits/habit'

module Habits
  
  module Whip
    extend self
    
    def self.on_transition_to(status, &blk)
      @@transitions ||= {}
      @@transitions[status] = blk
    end
    
  end
  
end

config = File.join(Habits::Habit::HABITS_DIR, 'whip_config.rb')
require config if File.exists?(config)
