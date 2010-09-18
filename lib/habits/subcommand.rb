# A minimal command line parser which focuses on handling subcommands.
# CMD SUBCOMMAND ARG1 ARG2 ...
#
# * default is used when just the command is given
# * last argument can be optional if surrounded by []
#
# E.g.
# Subcommand.register('create', ['TITLE', '[DAYS]'], 'Create something..') do |title, days|
#   ...
# end
# 
# Subcommand.parse
#
class Subcommand
  attr_reader :subs
  
  class Cmd
    attr_reader :args, :desc, :blk
    
    def initialize(args, desc, blk)
      @args, @desc, @blk = args, desc, blk
      @optional = @args.pop if @args.last =~ /^\[.*\]$/
    end
    
    def args_str
      (@args + [@optional]).compact.join(' ')
    end
    
    # Parse @call_args for this command
    def parse(args)
      if (args.size == @args.size) or (@optional and args.size == @args.size+1)
        @call_args = args
      else
        raise "Invalid arguments."
      end
    end
    
    # Trigger this command
    def call
      if @optional # provide nil for the optional arg in block if needed
        args = @call_args
        args << nil if @call_args.size == @args.size
        blk.call *args
      else
        blk.call *@call_args
      end
    end
  end

  def initialize
    @default = nil
    @subs = {}
  end
  
  # Register a command with name, arguments, description, and block (blk).
  # The block is called with as many input args as you defined in 'args'
  def register(cmd_name, args, desc, &blk)
    @subs ||= {}
    @subs[cmd_name] = Cmd.new(args, desc, blk)
  end
  
  # Set the default command to be called when just the executable is run.
  def default(&blk)
    @default = blk
  end
  
  # Parse command line arguments according to registered commands.
  def parse(args=ARGV)
    if args.size == 0
      @default.call if @default
      return
    end
    
    sub = @subs[args.shift]
    
    help and return if sub.nil?
    
    begin
      sub.parse(args)
      sub.call
    rescue Exception => e
      puts e.message
      help
    end
  end
  
  # Print help of available commands.
  def help
    puts "\nUsage: #{File.basename($0)} {command} arg1 arg2 ...\n\nCommand        Args"+
         ' '*32+"Description"
    @subs.keys.sort.each do |name|
      printf("  %-12s %-35s %s\n", name, @subs[name].args_str, @subs[name].desc)
    end
    puts
    true
  end
  
end