require 'time'
require 'habits'
require 'habits/subcommand'

def get_habit(title)
  h = Habits::Habit.all.detect{|h| h.title == title.strip}
  raise "No such habit found." unless h
  h
end

Subcommand.register('whip', [], 'Use the whip') do
  Habits::Whip.use
end

Subcommand.register('delete', ['TITLE'], 'Delete habit.') do |title|
  h = get_habit(title)
  h.destroy
  puts "#{h.title} deleted."
end

Subcommand.register('create', ['TITLE','DAYS'], 'Create a new habit.') do |title, days|
  days = days.split(',')
  if days.detect{|d| Time::RFC2822_DAY_NAME.index(d).nil?}
    puts "Valid days are #{Time::RFC2822_DAY_NAME.join(',')}"
  else
    Habits::Habit.new(title, days).save
    puts "Habit \"#{title}\" created."
  end
end

Subcommand.register('list', [], 'List habits.') do
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

Subcommand.register('zones', ['TITLE','YELLOW_ZONE','RED_ZONE'], 
                    "Set habit's yellow and red zones.") do |title, yellow, red|
  h = get_habit(title)

  h.yellow_zone = yellow.to_i * 60 * 60
  h.red_zone = red.to_i * 60 * 60
  h.save
  puts "Zones set."
end

Subcommand.register('act', ['TITLE', '[HOURS]'], 
                    "Add activity to habit, hours optional.") do |title, hours|
  h = get_habit(title)
  h.add_event(Habits::Events::Activity.new(hours ? hours.to_i : nil))
  puts "Added."
end

Subcommand.default do
  Subcommand.subs['list'].blk.call
end

Subcommand.parse