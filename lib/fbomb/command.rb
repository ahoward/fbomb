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
      fattr(:command_paths){ [] }

      def load(*args)
        args.flatten.uniq.each do |arg|
          Command.command_paths << arg
          case arg.to_s
            when %r|^[/~]|
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
          open(path){|fd| load_string(fd.read, uri, 1)}
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
        open(path){|fd| load_string(fd.read, path, 1)}
      end

      def load_string(string, __file__, __lineno__, dangerous = true)
        Thread.new(string, dangerous) do |string, dangerous|
          Thread.current.abort_on_exception = true
          $SAFE = 12 unless dangerous
          module_eval(string, __file__, __lineno__)
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
      arity = @call.arity

      argv =
        if arity >= 0
          args[0, arity]
        else
          head = []
          tail = []
          n = arity.abs - 1
          head = args[0...n]
          tail = args[n..-1]
          [*(head + tail)]
        end

      argv.compact!

      block ? @call=call : instance_exec(*argv, &@call)
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

    %w( upload ).each do |method|
      module_eval <<-__, __FILE__, __LINE__
        def #{ method }(file, content_type = nil, filename = nil)
          room ? room.#{ method }(file, content_type, filename) : p(file, content_type, filename)
          file
        end
      __
    end

    def most_recent_comment
      message =
        catch(:message) do
          FBomb.messages.reverse.each do |message|
            next if message == FBomb.message

            case message['type'].to_s
              when 'TextMessage'
                throw :message,  message
            end
          end
          nil
        end
      message['body'] if message
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
