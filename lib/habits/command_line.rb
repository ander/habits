require 'time'
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
  days = days.split(',')
  if days.detect{|d| Time::RFC2822_DAY_NAME.index(d).nil?}
    puts "Valid days are #{Time::RFC2822_DAY_NAME.join(',')}"
  else
    Habits::Habit.new(title, days).save
    puts "Habit \"#{title}\" created."
  end
end
  
sub.register('list', [], 'List habits.') do
  puts "\nHABIT                          DAYS                           STATUS     YELLOW/RED"
  puts "===================================================================================\n"
  Habits::Habit.all.each do |habit|
    printf("%-30s %-30s %-10s [%dh / %dh]\n", 
           habit.title, habit.days.join(','),
           habit.status.value.to_s.capitalize,
           (habit.yellow_zone / (60*60)),
           (habit.red_zone / (60*60)))
  end
  puts "===================================================================================\n"
  puts "\nTotal #{Habits::Habit.all.size} habits.\n"
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
  h.add_event(Habits::Events::Activity.new(hours ? hours.to_i : nil))
  puts "Activity added."
end
  
sub.default do
  sub.subs['list'].blk.call
end

sub.parse