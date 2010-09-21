
spec = Gem::Specification.new do |spec|
  spec.author = "Antti Hakala"
  spec.email = 'antti.hakala@gmail.com'
  spec.homepage = 'http://github.com/ander/habits'
  spec.name = 'habits'
  spec.version = '0.1'
  spec.executables = ['habits']
  spec.files = ['README', 'LICENSE', 'bin/habits', 'whip_config.rb'] + Dir['lib/**/*.rb']
  spec.description = "A habit tracker. Tracks habits in weekly cycles."+
                     "Each habit has a day or days associated with it."+
                     "Habits expects activity on the habit on those days. "+
                     "If no activity is registered, habit goes first into yellow zone "+
                     "(e.g. 20 hours before deadline) and then into "+
                     "red zone (e.g. 6 hours). And finally into missed state."+
                     "Transfer into each state can be used to trigger commands."
  spec.summary = 'A habit tracker.'
end