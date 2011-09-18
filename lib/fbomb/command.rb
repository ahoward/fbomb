module FBomb
## class_methods
#
  class Command
    class Table < ::Map
      def help
        map = Map.new
        each do |path, command|
          map[path] = command.description
        end
        map
      end
    end

    class << Command
      fattr(:table){ Table.new }
      fattr(:dir){ File.join(File.expand_path(File.dirname(__FILE__)), 'commands') }
      fattr(:room)

      def load(*args)
        args.flatten.uniq.each do |arg|
          case arg.to_s
            when %r|^/|
              load_absolute_path(arg)
            when %r|://|
              load_uri(arg)
            else
              load_relative_path(arg)
          end
        end
        setup
        table
      end

      def commands
        table.values
      end

      def setup
        commands.each do |command|
          if command.setup and command.setup.respond_to?(:call)
            command.setup.call()
            command.setup = true
          end
        end
      end

      def load_uri(arg)
        uri = arg.to_s
        open(uri) do |fd|
          open(path){|fd| load_string(fd.read)}
        end
      end

      def load_relative_path(arg)
        basename = arg.to_s
        basename += '.rb' unless basename =~ /\.rb\Z/
        load_absolute_path(File.join(Command.dir, basename))
      end

      def load_absolute_path(arg)
        path = File.expand_path(arg.to_s)
        path += '.rb' unless path =~ /\.rb\Z/
        open(path){|fd| load_string(fd.read)}
      end

      def load_string(string, dangerous = true)
        Thread.new(string, dangerous) do |string, dangerous|
          Thread.current.abort_on_exception = true
          $SAFE = 12 unless dangerous
          Kernel.eval(string)
        end.value
      end
    end

## instance methods
#
    fattr(:room){ self.class.room }
    fattr(:path)
    fattr(:help)
    fattr(:setup)

    def initialize
      @call = proc{}
    end

    def call(*args, &block)
      block ? @call=call : instance_exec(*args, &@call)
    end

    def call=(call)
      @call = call
    end

    %w( speak paste ).each do |method|
      module_eval <<-__, __FILE__, __LINE__
        def #{ method }(*args, &block)
          room ? room.#{ method }(*args, &block) : puts(*args, &block)
        end
      __
    end

## dsl
#
    class DSL
      instance_methods.each{|m| undef_method(m) unless m.to_s =~ /(^__)|object_id/}

      def DSL.evaluate(*args, &block)
        dsl = new
        dsl.evaluate(*args, &block)
        dsl
      end

      def initialize
        @commands = Command.table
      end

      def evaluate(*args, &block)
        Object.instance_method(:instance_eval).bind(self).call(&block)
      end

      def command(*args, &block)
        return @command if(args.empty? and block.nil?)
        @command = Command.new
        @command.path = Util.absolute_path_for(args.shift)
        @commands[@command.path] ||= @command
        evaluate(&block)
      end
      alias_method('Command', 'command')

      def help(*args)
        @command.help = args.join("\n")
      end

      def setup(&block)
        @command.setup = block
      end

      def call(&block)
        @command.call = block
      end
    end
  end
end
