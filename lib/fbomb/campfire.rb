module FBomb
  class Campfire < ::Tinder::Campfire
    module SearchExtension
      def search(term)
        room = self
        term = CGI.escape(term.to_s)
        return_to_room_id = CGI.escape(room.id.to_s)
        messages = connection.get("/search?term=#{ term }&return_to_room_id=#{ return_to_room_id }")
        if messages and messages.is_a?(Hash)
          messages = messages['messages']
        end
        messages.each do |message|
          message['created_at_time'] = Time.parse(message['created_at'])
        end
        messages.replace(messages.sort_by{|message| message['created_at_time']}) 
        messages
      end
    end

    module UserExtension
      Cached = {}

      def user(id)
        user = Cached[id]
        return user if user

        if id
          user = users.detect{|u| u[:id] == id}
          unless user
            user_data = connection.get("/users/#{ id }.json")
            user = user_data && user_data['user']
          end
          user['created_at'] = Time.parse(user['created_at'])
          Cached[id] = user
        end
      end
    end

    module StreamExtension
      def stream
        @stream ||= (
          room = self
          Twitter::JSONStream.connect(
            :path => "/room/#{ room.id }/live.json",
            :host => 'streaming.campfirenow.com',
            :auth => "#{ connection.token }:x"
          )
        )
      end

      def streaming(&block)
        steam.instance_eval(&block)
      end
    end

    module UrlExtension
      attr_accessor :campfire

      def url
        File.join(campfire.url, "room/#{ id }")
      end
    end

    def Campfire.new(*args, &block)
      allocate.tap do |instance|
        instance.send(:initialize, *args, &block)
      end
    end

    def room_for(name)
      name = name.to_s
      room = rooms.detect{|_| _.name == name}
      room.extend(SearchExtension)
      room.extend(UserExtension)
      room.extend(StreamExtension)
      room.extend(UrlExtension)
      room.campfire = self
      room
    end

    attr_accessor :token

    def url
      if token
        "#{ scheme }://#{ token }:X@#{ host }"
      else
        "#{ scheme }://#{ host }"
      end
    end

    def host
      connection.raw_connection.host
    end

    def scheme
      connection.raw_connection.scheme
    end
  end
end
