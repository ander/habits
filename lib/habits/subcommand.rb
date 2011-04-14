#
# A minimal command line parser for subcommands.
# CMD SUBCOMMAND ARG1 ARG2 ...
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

  attr_accessor :auto_help

  def initialize
    @default = nil
    @subs = {}
    @auto_help = false
  end
  
  # Register a command with name, arguments, description, and block (blk).
  # The block is called with as many input args as you defined in 'args'
  def register(cmd_name, args, desc, &blk)
    @subs ||= {}
    @subs[cmd_name] = Cmd.new(args, desc, blk)
  end
  
  # Set the default command to be called when just the executable is run.
  def default(&blk)
    raise "No block given" unless blk
    @default = blk
  end
  
  # Set the default command to be one of the registered subcommands
  def default=(cmd_name)
    raise "No subcommand #{cmd_name} registerd" if @subs[cmd_name].nil?
    @default = @subs[cmd_name].blk
  end
  
  # Parse command line arguments according to registered commands.
  def parse(args=ARGV)
    if args.size == 0
      @default.call if @default
      return
    end
    
    sub = @subs[args.shift]
    
    if sub.nil?
      puts "Unknown command."
      help if auto_help
      return
    end
    
    begin
      sub.parse(args)
      sub.call
    rescue Exception => e
      puts e.message
      help if auto_help
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