#
# a habits whip config file
#
# Store in $HOME/.habits/whip_config.rb
#

def dialog(title, txt)
  system %Q(say '#{title}')
  system %Q(osascript -e 'tell app "System Events" to display dialog "#{txt}"')
  # or if you have 'ruby-growl' gem installed
  # system "growl -h localhost -m '#{txt}'"
end

Habits::Whip.on(:yellow) do |habit|
  dialog habit.title, "[HABITS] #{habit.title} is now in yellow."
end

Habits::Whip.on(:red) do |habit|
  dialog habit.title, "[HABITS] #{habit.title} is now in RED!"
end

Habits::Whip.on(:missed) do |habit|
  dialog habit.title, "[HABITS] #{habit.title} MISSED!"
end