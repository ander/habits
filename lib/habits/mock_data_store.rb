
module Habits
  
  # a module to  in Habit to mock data storing
  class Habit
    
    def self.all
      @@all
    end
    
    def self.all=(habits)
      @@all = habits
    end
    
    def save
      # do nothing
    end
    
    def destroy
      # do nothing
    end
    
  end
  
end