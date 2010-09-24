require 'time'
require 'date'
require 'habits'
require 'habits/subcommand'

sub = Subcommand.new

sub.register('whip', [], 'Use the whip') do
  Habits::Whip.use
end
  
sub.register('delete', ['TITLE'], 'Delete habit.') do |title|
  h = Habits::Habit.find(title)
  h.destroy
  puts "#{h.title} deleted."
end
  
sub.register('create', ['TITLE','DAYS'], 'Create a new habit.') do |title, days|
  Habits::Habit.new(title, days.split(',')).save
  puts "Habit \"#{title}\" created."
end
  
sub.register('list', [], 'List habits.') do
  puts "\nHABIT                     DAYS                           STATUS     YELLOW/RED"
  puts "===============================================================================\n"
  Habits::Habit.all.each do |habit|
    printf("%-25s %-30s %-10s [%dh / %dh]\n", 
           habit.title, habit.days.join(','),
           habit.status.value.to_s.capitalize,
           (habit.yellow_zone / (60*60)),
           (habit.red_zone / (60*60)))
  end
  puts "===============================================================================\n"
  puts "\nWeek #{Date.today.cweek} | Total #{Habits::Habit.all.size} habits.\n\n"
end

sub.register('zones', ['TITLE','YELLOW_ZONE','RED_ZONE'], 
             "Set habit's yellow and red zones.") do |title, yellow, red|
  h = Habits::Habit.find(title)

  h.yellow_zone = yellow.to_i * 60 * 60
  h.red_zone = red.to_i * 60 * 60
  h.save
  puts "Zones set."
end
  
sub.register('do', ['TITLE', '[HOURS]'], 
             'Add activity to habit, hours optional.') do |title, hours|
  h = Habits::Habit.find(title)
  h.add_event(Habits::Events::Activity.new(hours ? hours.to_f : nil))
  puts "Activity added."
end

sub.register('rename', ['TITLE', 'NEW_TITLE'], 'Rename habit.') do |title, new_title|
  h = Habits::Habit.find(title)
  h.set_title(new_title)
  puts "Renamed #{title} -> #{new_title}"
  h.save
end

sub.register('show', ['TITLE'], 'Show activity of habit.') do |title|
  h = Habits::Habit.find(title)
  
  if h.events.empty?
    puts "\nNo activity.\n\n"
  else
    puts "\n#{title} Activity:\n"+ ('='*(title.size)) + "==========\n"
  
    h.events.each do |event|
      str = "  #{event.applied_at.strftime("%a %b %d %Y")}"
      str += " #{event.duration} hours" if event.duration
      puts str
    end
    puts
  end
end

sub.register('split', ['TITLE'], 'Split a habit into days.') do |title|
  h = Habits::Habit.find(title)
  h.split!
  puts "Habit \"#{title}\" split."
end

sub.register('join', ['TITLE', '[OTHER_TITLE]'], 
             'Join habits. First one is kept.') do |title, other_title|
  if other_title.nil?
    Habits::Habit.join_all(title)
    puts "#{title} joined."
  else
    habit = Habits::Habit.find(title)
    other = Habits::Habit.find(other_title)
    habit.join!(other)
    puts "Habits \"#{title}\" and \"#{other_title}\" joined."
  end
end

sub.default = 'list'

sub.parse