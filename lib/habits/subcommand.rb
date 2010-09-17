# A minimal command line parser which focuses on handling subcommands.
# CMD SUBCOMMAND ARG1 ARG2 ...
#
# * default is used when just the command is given
# * last argument can be optional if surrounded by []
#
# E.g.
# Subcommand.register('create', ['TITLE', '[DAYS]']) do |title, days|
#   ...
# end
# 
# Subcommand.parse
#
module Subcommand
  extend self
  @@default = nil
  @@subs = {}
  
  def subs; @@subs end
  
  class Cmd
    attr_reader :args, :desc, :blk
    
    def initialize(args, desc, blk)
      @args, @desc, @blk = args, desc, blk
      @optional = @args.pop if @args.last =~ /^\[.*\]$/
    end
    
    def args_str
      (@args + [@optional]).compact.join(' ')
    end
    
    def parse(args)
      if (args.size == @args.size) or (@optional and args.size == @args.size+1)
        @call_args = args
      else
        raise "Invalid arguments."
      end
    end
    
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
  
  def register(cmd_name, args, desc, &blk)
    @@subs ||= {}
    @@subs[cmd_name] = Cmd.new(args, desc, blk)
  end
  
  def default(&blk)
    @@default = blk
  end
  
  def parse(args=ARGV)
    if args.size == 0
      @@default.call if @@default
      return
    end
    
    sub = @@subs[args.shift]
    
    print_usage and return if sub.nil?
    
    begin
      sub.parse(args)
      sub.call
    rescue Exception => e
      puts e.message
      print_usage
    end
  end
  
  def print_usage
    puts "\nUsage: #{File.basename($0)} {command} arg1 arg2 ...\n\nCommand        Args"+
         ' '*32+"Description"
    @@subs.keys.sort.each do |name|
      printf("  %-12s %-35s %s\n\n", name, @@subs[name].args_str, @@subs[name].desc)
    end
    true
  end
end