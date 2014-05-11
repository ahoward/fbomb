module FBomb
  class Flowdock
    fattr(:organization)
    fattr(:flow)
    fattr(:token)
    fattr(:options)
    fattr(:client)
    fattr(:client_options)

    def initialize(organization, flow, token, options = {})
      raise ArgumentError.new('no organization') if organization.to_s.strip.empty?
      raise ArgumentError.new('no flow') if flow.to_s.strip.empty?
      raise ArgumentError.new('no token') if token.to_s.strip.empty?

      @organization = Organization.new(organization, self)
      @flow = Flow.new(flow, self)
      @token = String.new(token)

      @options = Map.for(options)
      @client_options = Map.for(@options.get(:client))

      unless @client_options.has_key?(:token)
        unless @token.empty?
          @client_options[:api_token] ||= @token
        end
      end

      @client = ::Flowdock::Flow.new(@client_options)
    end

    class Object
      fattr(:name)
      fattr(:flowdock)

      def initialize(name, flowdock)
        @name = name.to_s.strip.downcase
        @flowdock = flowdock
      end

      def to_s
        name
      end

      def to_str
        name
      end

      %w( organization flow token client options ).each do |method|
        class_eval <<-__
          def #{ method }(*args, &block)
            flowdock.#{ method }(*args, &block) if flowdock
          end
        __
      end
    end

    class Organization < Object
    end

    class Flow < Object
      def escape(string)
        string.to_s.gsub('+', '%2B')
      end

      def tags_for(*tags)
        Coerce.list_of_strings(*tags).map{|tag| "##{ tag }".gsub(/^[#]+/, '#')}
      end

      def speak(*args, &block)
        options = Map.options_for!(args)
        tags = tags_for(options[:tags], options[:tag])

        content = escape(Coerce.list_of_strings(args).join(' '))

        msg = {:content => content, :tags => tags}

        if FBomb.debug
          puts("SPEAK\n")
          puts(msg.to_yaml)
          puts
        else
          client.push_to_chat(msg)
        end
      end

      alias_method(:say, :speak)

      def paste(*args, &block)
        options = Map.options_for!(args)
        tags = tags_for(options[:tags], options[:tag])

        content =
          case
            when args.size == 1
              if args.first.is_a?(String)
                args.first
              else
                Coerce.array(args.first).join("\n")
              end
            else
              Coerce.list_of_strings(args).join("\n")
          end

        msg = {:content => Util.indent(escape(content), 4), :tags => tags}

        if FBomb.debug
          puts("PASTE\n")
          puts(msg.to_yaml)
          puts
        else
          client.push_to_chat(msg)
        end
      end

      def upload(*args, &block)
        raise NotImplementedError
      end

      def users(*args, &block)
        []
      end

      def leave
        say 'bai'
      end

=begin
  {"event"=>"activity.user",
   "tags"=>[],
   "uuid"=>nil,
   "persist"=>false,
   "id"=>194342,
   "flow"=>"c6dbc029-2173-4fb6-a423-32293c373106",
   "content"=>{"last_activity"=>1399656686378},
   "sent"=>1399657205286,
   "app"=>nil,
   "attachments"=>[],
   "user"=>"76002"}

   {:flow=>{"event"=>"message",
    "tags"=>[],
     "uuid"=>"Ry2GHegX445OAxV_",
      "id"=>2427,
       "flow"=>"affcb403-0c5f-4a2c-89a6-a809a887e281",
        "content"=>".peeps",
         "sent"=>1399838702954,
          "app"=>"chat",
           "attachments"=>[],
            "user"=>"77414"}
            }

=end
      def stream(&block)
        return debug_stream(&block) if FBomb.debug

        http = EM::HttpRequest.new(
          "https://stream.flowdock.com/flows/#{ organization }/#{ flow }",
          :keepalive => true, :connect_timeout => 0, :inactivity_timeout => 0)

        EventMachine.run do
          s = http.get(:head => { 'Authorization' => [token, ''], 'accept' => 'application/json'})

          buffer = ""
          s.stream do |chunk|
            buffer << chunk
            while line = buffer.slice!(/.+\r\n/)
              begin
                flow = JSON.parse(line)

                unless flow['event'] == 'activity.user'
                  history.push(flow)

                  while history.size > 1024
                    history.shift
                  end
                end

                if flow['external_user_name'] == client.external_user_name
                  next
                end

                block.call(Map.for(flow)) if block
              rescue Object => e
                warn("#{ e.message }(#{ e.class })#{ Array(e.backtrace).join(10.chr) }")
                # FIXME 
              end
            end
          end
        end
      end

      def debug_stream(&block)
        require "readline"

        while buf = Readline.readline("#{ organization }/#{ flow } > ", true)
          if buf.strip.downcase == 'exit'
            exit
          end

          flow = {
            :event       => 'message',
            :content     => buf,
            :tags        => [],
            :persist     => false,
            :id          => rand(99999),
            :uuid        => FBomb.uuid,
            :sent        => Time.now.to_i,
            :app         => 'fbomb',
            :attachments => [],
            :user        => rand(99999),
          }

          block.call(Map.for(flow)) if block
        end
      end

      def history
        @history ||= []
      end

      def users
        url = "https://#{ token }:@api.flowdock.com/flows/#{ organization }/#{ flow }/users"
        key = url

        cache.fetch(key) do
          json = `curl -s #{ url.inspect }` # FIXME - boo for shelling out ;-/
          array = JSON.parse(json)
          users = array.map{|u| User.for(u)}
        end
      end

      def user_for(id)
        users.detect{|user| user.id.to_s == id.to_s || user.email.to_s == id.to_s}
      end

      def cache
        Cache
      end
    end

    module Cache
      TTL = 3600

      def read(key)
        entry = _cache[key]

        return nil unless entry

        value, cached_at = entry
        expired = (Time.now - cached_at) > TTL

        if expired
          _cache.delete(key)
          nil
        else
          value
        end
      end

      def write(key, value)
        cached_at = Time.now
        entry = [value, cached_at]
        _cache[key] = entry
        value
      end

      def _cache
        @_cache ||= Map.new
      end

      def fetch(key, &block)
        entry = _cache[key]

        if entry
          value, cached_at = entry
          expired = (Time.now - cached_at) > TTL

          if expired
            begin
              write(key, block.call)
            rescue Object => e
              warn "#{ e.message }(#{ e.class })"
              value
            end
          else
            value
          end
        else
          write(key, block.call)
        end
      end

      extend(Cache)
    end

=begin
    users = JSON.parse(`curl -s
        https://829ac2ae34fd4c8998cf6220d43dd3de:@api.flowdock.com/flows/dojo4/dojo4/users`).map{|u|
            Map.for(u)}
=end
    class User < ::Map
    end

    class Token < Object
    end
  end
end
