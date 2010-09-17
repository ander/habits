#
# a habits whip config file
#
# Store in $HOME/.habits/whip_config.rb
#

def dialog(txt)
  system %Q(osascript -e 'tell app "System Events" to display dialog "#{txt}"')
end

Habits::Whip.on(:yellow) do |habit|
  dialog "[HABITS] #{habit.title} is now in yellow."
end

Habits::Whip.on(:red) do |habit|
  dialog "[HABITS] #{habit.title} is now in RED!"
end

Habits::Whip.on(:missed) do |habit|
  dialog "[HABITS] #{habit.title} MISSED!"
end