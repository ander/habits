require 'time'
require 'date'
require 'habits'
require 'habits/subcommand'
require 'fileutils'

if !File.exists?(Habits::Habit::HABITS_DIR)
  FileUtils.mkdir Habits::Habit::HABITS_DIR
  FileUtils.cp File.join(File.dirname(__FILE__), '..', '..', 'whip_config.rb'), 
               Habits::Habit::HABITS_DIR+"/"
  puts "\n*** Copied default whip_config.rb to #{Habits::Habit::HABITS_DIR}"
  puts "*** Please edit it to suit you."
  puts "*** Also, consider adding line '0   *   *   *   *   /usr/bin/habits whip'"
  puts "*** to your crontab.\n"
end

sub = Subcommand.new

sub.register('whip', [], 'Use the whip.') do
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
  Habits::Habit.all_not_on_hold.each do |habit|
    printf("%-25s %-30s %-10s [%dh / %dh]\n", 
           habit.title, habit.days.join(','),
           habit.status.value.to_s.capitalize,
           (habit.yellow_zone / (60*60)),
           (habit.red_zone / (60*60)))
  end
  puts "===============================================================================\n"
  on_hold = Habits::Habit.all_on_hold
  
  if on_hold.size > 0
    puts "\nOn Hold:\n--------" 
    on_hold.each do |habit|
      puts "* #{habit.title}"
    end
  end
  
  puts "\nWeek #{Date.today.cweek} | Total #{Habits::Habit.all.size} habits "+
       "| #{Habits::Habit.missed_count} missed\n\n"
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

sub.register('hold', ['TITLE'], 'Put a habit on hold.') do |title|
  h = Habits::Habit.find(title)
  h.hold
  puts "Habit \"#{title}\" is now on hold."
end

sub.register('unhold', ['TITLE'], 'Unhold a habit.') do |title|
  h = Habits::Habit.find(title)
  h.unhold
  puts "Habit \"#{title}\" is not on hold anymore."
end


sub.default = 'list'

sub.parse