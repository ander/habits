require 'habits/habit'

module Habits
  
  module Whip
    extend self
    @@transitions = {}
    @@ticks = []
    
    # Add block to be executed when status changes to given status.
    # A habit which changes to this status is passed to the block.
    def on(status, &blk)
      raise "No block given" if blk.nil?
      @@transitions[status] = blk
    end
    
    # Add a block to be called each time before whip is used.
    def on_tick(&blk)
      raise "No block given" if blk.nil?
      @@ticks << blk
    end
    
    # Use whip, i.e. update status of each habit and call
    # blocks associated with state changes.
    def use
      @@ticks.each {|tick| tick.call}
      
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
