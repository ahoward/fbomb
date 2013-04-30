FBomb {


##
#
  command(:chuckle) {
    help "Ha ha, very funny."
    setup{ require "google-search" }

    call do |*args|
      uris = []
      images = Google::Search::Image.new(:query => 'funny safety signs', :image_size => :medium)
      images.each { |result| uris << result.uri }
      speak(uris.sort_by { rand }.first)
    end
  }

##
#
  command(:elevator){
    help "Give me the pitch."

    call do |*args| 
      message = [
        "We're %s %s.",
        "I said \"%s %s\" and the room got really quiet.",
        "We are going after a billion-dollar market with %s %s.",
        "If you can't sell %s %s, you can't sell anything.",
        "I've got it! \"Sometimes you feel like a nut, sometimes you're %s %s.\""
      ].sort_by { rand }.first
      
      description = `curl --silent 'http://itsthisforthat.com/api.php?text'`
      re = %r|So, Basically, It's Like A (.*)\.|
      description.sub!(/^So, Basically, It's Like A /, '').chomp!(".")

      article = description[0] =~ /^[aeiou]/i ? 'an' : 'a'

      speak(format(message, article, description))
    end
  }
##
#
  command(:reload){
    help 'reload fbomb commands'

    call do |*args|
      FBomb::Command.table = FBomb::Command::Table.new
      FBomb::Command.load(Command.command_paths)
      speak('locked and loaded.')
    end
  }

##
#
  command(:rhymeswith) {
    help 'show ryhming words'

    setup{ require 'cgi' }

    call do |*args|
      args.each do |arg|
        if arg.strip == 'orange'
          speak('nothing rhymes with orange dumbass')
        else
          word = CGI.escape(arg.strip)
          url = "http://www.zachblume.com/apis/rhyme.php?format=xml&word=#{ word }"
          data = `curl --silent #{ url.inspect }`
          words = data.scan(%r|<word>([^<]*)</word>|).flatten
          msg = words.join(" ")
          speak(msg)
        end
      end
    end
  }

##
#
  command(:chucknorris) {
    call do |*args|
      data = JSON.parse(`curl --silent 'http://api.icndb.com/jokes/random'`)
      msg = data['value']['joke']
      speak(msg) unless msg.strip.empty?
    end
  }

##
#
  command(:fukung) {
    call do |*args|
      tags = args.join(' ').strip.downcase
      if tags.empty?
        msg = Array(Fukung.random).sort_by{ rand }.first(3).join("\n")
      else
        msg = Fukung.tag(tags).sort_by{ rand }.first(3).join("\n")
      end
      speak(msg) unless msg.strip.empty?
    end
  }

##
#
  command(:google) {
    setup{ require "google-search" }

    call do |*args|
      type = args.first
      msg = ""
      case type
        when /image|img|i/i
          args.shift
          query = args.join(' ')
          @cache ||= []
          images = Google::Search::Image.new(:query => query, :image_size => :small)
          if images.any?
            images.each do |result|
              next if @cache.include? result.id
              @cache << result.id
              msg = "#{ result.uri }\n"
              break
            end
          else
            msg = "No results for: #{query}"
          end
        else
          query = args.join(' ')
          Google::Search::Web.new(:query => query).each do |result|
            msg << "#{ result.uri }\n"
          end
      end
      speak(msg) unless msg.empty?
    end
  }

##
#
  command(:fail){
    setup{ require "nokogiri"}

    call do |*args|
      msg = ""
      query = CGI.escape(args.join(' ').strip)
      url = "http://failblog.org/?s=#{query}"
      data = `curl --silent #{ url.inspect }`
      doc = Nokogiri::HTML(data)
      images = doc.search('div.entry img').collect{|i| i.get_attribute('src')}
      @cache ||= []
      if images.any?
        images.each do |result|
          next if @cache.include? result
          @cache << result
          msg = "#{ result }\n"
          break
        end
      else
        msg = "No results for: #{query}"
      end
      speak(msg) unless msg.empty?
    end
  }

##
#
  command(:gist) {
    call do |*args|
      url = args.join(' ').strip

      id = url.scan(/\d+/).first
      gist_url = "https://gist.github.com/#{ id }"
      speak(gist_url)

      gist_html = `curl --silent #{ gist_url.inspect }`
      re = %r| <a\s+href\s*=\s*" (/raw[^">]+) "\s*>\s*raw\s*</a> |iox
      match, raw_path = re.match(gist_html).to_a

      if match
        raw_url = "https://gist.github.com#{ raw_path }"
        raw_html = `curl --silent --location #{ raw_url.inspect }`
        paste(raw_html)
      end
    end
  }

##
#
  command(:xkcd) {
    call do |*args|
      id = args.shift || rand(1000)
      url = "http://xkcd.com/#{ id }/"
      html = `curl --silent #{ url.inspect }`
      doc = Nokogiri::HTML(html)
      links = []
      doc.xpath('//h3').each do |node|
        text = node.text
        case text
          when %r'Permanent link to this comic:', %r'hotlinking/embedding'
            link = text.split(':').last
            link = "http:#{ link }" unless link['://']
            links << link
        end
      end
      links.each do |link|
        speak(link)
      end
    end
  }

##
#
  command(:goodfuckingdesignadvice) {
    call do |*args|
      url = "http://goodfuckingdesignadvice.com/index.php"
      html = `curl --location --silent #{ url.inspect }`
      doc = Nokogiri::HTML(html)
      msg = nil
      doc.xpath('//div').each do |node|
        if node['class'] =~ /advice/
          text = node.text
          msg = text
        end
      end
      speak(msg) if msg
    end
  }

##
#
  command(:designquote) {
    call do |*args|
      url = "http://quotesondesign.com"
      cmd = "curl --location --silent #{ url.inspect }"
      html = `#{ cmd  }`
      id = rand(10)
      doc = Nokogiri::HTML(html)
      msg = nil
      doc.xpath('//div').each do |node|
        if node['id'] =~ /post-/
          text = node.text
          break(msg = text)
        end
      end
      if msg
        msg = msg.gsub(%r'\[\s+permalink\s+\]', '').gsub(%r'\[\s+Tweet\s+This\s+\]', '').strip
        msg = Unidecoder.decode(msg)
        speak(msg)
      end
    end
  }

##
#
  command(:quote) {
    call do |*args|
      url = "http://iheartquotes.com/api/v1/random?format=html&max_lines=4&max_characters=420"
      html = `curl --location --silent #{ url.inspect }`
      doc = Nokogiri::HTML(html)
      msg = nil
      #<a target="_parent" href='http://iheartquotes.com/fortune/show/victory_uber_allies_'>Victory uber allies!</a>
      doc.xpath('//div[@class="rbcontent"]/a').each do |node|
        text = node.text
        msg = text
      end
      speak(msg) if msg
    end
  }

##
#
  command(:people){
    call do |*args|
      msgs = []
      room.users.each do |user|
        name = user['name']
        email_address = user['email_address']
        avatar_url = user['avatar_url']
        speak(avatar_url)
        speak("#{ name } // #{ email_address }")
      end
    end
  }

##
#
  command(:peeps){
    call do |*args|
      msgs = []
      room.users.each do |user|
        name = user['name']
        email_address = user['email_address']
        msgs.push("#{ name }")
      end
      speak(msgs.join(', '))
    end
  }

##
#
  command(:rawk){
    call do |*args|
      urls = %w(
        http://s3.amazonaws.com/drawohara.com.images/angus1.gif
        http://img.maniadb.com/images/artist/117/117027.jpg
        http://images.starpulse.com/Photos/pv/Van%20Halen-7.JPG
      )
      speak(urls[rand(urls.size)])
    end
  }

  command(:certified) {
    call do |*args|
      urls = %w(
        http://blog.pravesh.me/files/2012/08/worksonmymachine.jpg
        http://4.bp.blogspot.com/_CywCAU4HORs/S-HYtX4vOkI/AAAAAAAAAHw/Hzi5PYZOkrg/s320/ItWorksOnMyMachine.jpg
        http://people.scs.carleton.ca/~mvvelzen/pH/works-on-my-machine-stamped.png
        http://cdn.memegenerator.net/instances/400x/24722869.jpg
        http://sd.keepcalm-o-matic.co.uk/i/keep-calm-it-works-on-my-machine.png
      )
      speak(urls[rand(urls.size)])
    end
  }

##
#
  command(:meat){
    call do |*args|
      url = 'http://baconipsum.com/api/?type=meat-and-filler&paras=1'
      data = `curl --silent #{ url.inspect }`
      data.gsub!(/[\["\]]/, '')
      speak(data)
    end
  }

##
#
  command(:pixtress){
    call do |*args|
      url = "http://pixtress.tumblr.com/random"
      error = nil

      4.times do
        begin
          agent = Mechanize.new
          agent.open_timeout = 240
          agent.read_timeout = 240

          page = agent.get(url)

          page.search('//div[@class="ThePhoto"]/a').each do |node|
            node.search('//img').each do |img|
              src = img['src']
              alt = img['alt']
              url = src

              image = agent.get(src)

              Util.tmpdir do
                open(image.filename, 'w'){|fd| fd.write(image.body)}

                url = File.join(room.url, "uploads.xml")
                cmd = "curl -Fupload=@#{ image.filename.inspect } #{ url.inspect }"
                system(cmd)
                speak(alt)
              end

              break
            end
          end

          break
        rescue Object => error
          :retry
        end
      end

      raise error if error
    end
  }

##
#
  command(:shaka){
    call do |*args|
      speak('http://s3.amazonaws.com/drawohara.com.images/shaka.jpg')
    end
  }

##
#
  command(:unicorn){
    setup{ require "google-search" }

    urls = [
      'http://ficdn.fashionindie.com/wp-content/uploads/2010/04/exterface_unicorn_03.jpg',
      'http://fc04.deviantart.net/fs51/f/2009/281/a/7/White_Unicorn_My_Little_Pony_by_Barkingmadd.jpg',
      'http://th54.photobucket.com/albums/g119/jasonjmore/th_UnicornPeeingRainbow.jpg',
      'https://dojo4.campfirenow.com/room/279627/uploads/4343363/unicornattack11.png',
      'https://dojo4.campfirenow.com/room/279627/uploads/4343762/spirit-animal.jpg',
      'http://th242.photobucket.com/albums/ff99/1010496/th_unicornpr0n.gif'
    ]

    call do |*args|
      if args.first == 'bomb'
        n = Integer(args[1] || [3, rand(10)].max)
        images = Google::Search::Image.new(:query => 'unicorn', :image_size => :medium)
        images = images.map{|result| result.uri}.uniq.sort_by{ rand }
        n.times{ speak(msg = images.pop) }
      else
        speak(urls.sample)
      end
    end
  }

##
#
  command(:steve){
    setup{ require "google-search" }

    call do |*args|

      images = Google::Search::Image.new(:query => 'french+club', :image_size => :medium)
      images = images.map{|result| result.uri}.uniq.sort_by{ rand }
      speak(msg = "Livraison spéciale pour Chaps Bailey!")
      speak(msg = images.sample)
    end
  }

##
#
  command(:yak){
    setup{ require "google-search" }

    call do |*args|

      images = Google::Search::Image.new(:query => 'shaved+yak', :image_size => :medium)
      images = images.map{|result| result.uri}.uniq.sort_by{ rand }
      speak(msg = "Sometimes you just need a really close shave...")
      speak(msg = images.sample)
    end
  }

##
#
  command(:endoftheworld){
    setup{ require "google-search" }

    call do |*args|

      images = Google::Search::Image.new(:query => 'end+of+the+world+2012', :image_size => :large)
      images = images.map{|result| result.uri}.uniq.sort_by{ rand }
      speak(msg = "It's the end of the world as we know it...")
      speak(msg = images.sample)
    end
  }

##
#
  command(:hug){
    setup{ require "google-search" }

    call do |*args|

      images = Google::Search::Image.new(:query => 'fridayhug', :image_size => :medium)
      images = images.map{|result| result.uri}.uniq.sort_by{ rand }
      speak(msg = "Sometimes you just need a hug...")
      speak(msg = images.sample)
    end
  }


##
#
  command(:perfectlytimed){
    setup{ require "google-search" }

    call do |*args|

      images = Google::Search::Image.new(:query => 'perfectly+timed+photos', :image_size => :large)
      images = images.map{|result| result.uri}.uniq.sort_by{ rand }
      speak(msg = "Shazam!")
      speak(msg = images.sample)
    end
  }

##
#
  command(:octocat){
    setup{ require "google-search" }

    call do |*args|

      images = Google::Search::Image.new(:query => 'octocat+github', :image_size => :large)
      images = images.map{|result| result.uri}.uniq.sort_by{ rand }
      speak(msg = "Purrrrrrrr...")
      speak(msg = images.sample)
    end
  }

##
#
  command(:goodnews){
    setup{ require "google-search" }

    call do |*args|
      images = Google::Search::Image.new(:query => 'good+news+everyone+futurama', :image_size => :large)
      images = images.map{|result| result.uri}.uniq.sort_by{ rand }
      speak(msg = images.sample)
      speak(msg = args.join(" "))
    end
  }

##
#
  command(:ship_it){
    setup{ require "google-search" }

    call do |*args|

      images = Google::Search::Image.new(:query => 'github+ship+it+squirrel', :image_size => :large)
      images = images.map{|result| result.uri}.uniq.sort_by{ rand }
      speak(msg = "Ship it already!")
      speak(msg = "#{images.sample}#.png")
    end
  }

##
#
  command(:confession) {
    call do |*args|
      url = "http://dj4confessions.wordpress.com/"
      html = `curl --location --silent #{ url.inspect }`
      doc = Nokogiri::HTML(html)
      articles = doc.xpath("//article")
      # articles = doc.xpath("//*[contains(concat(' ', @class, ' '), ' hentry ')]")
      latest = articles.to_a.first(14)
      r = rand(14)
      article = latest[r]
      addressee = article.css('header h1').text.strip.upcase
      confession = article.css('.entry-content p').text.strip
      getimgsrc = article.css('.entry-content img').collect{|i| i.get_attribute('src')}
      image = getimgsrc.first
      speak(image) if image
      speak(addressee) if addressee
      speak(confession) if confession
    end
  }

##
#
  command(:quote) {
    call do |*args|
      url = "http://iheartquotes.com/api/v1/random?format=html&max_lines=4&max_characters=420"
      html = `curl --location --silent #{ url.inspect }`
      doc = Nokogiri::HTML(html)
      msg = nil
      #<a target="_parent" href='http://iheartquotes.com/fortune/show/victory_uber_allies_'>Victory uber allies!</a>
      doc.xpath('//div[@class="rbcontent"]/a').each do |node|
        text = node.text
        msg = text
      end
      speak(msg) if msg
    end
  }

##
#
  command(:peter){
    setup{ require "google-search" }

    call do |*args|

      images = Google::Search::Image.new(:query => 'cheetara', :image_size => :medium)
      images = images.map{|result| result.uri}.uniq.sort_by{ rand }
      speak(msg = "<3 <3 <3 first crush OMG!!1!")
      speak(msg = images.sample)
    end
  }
##
#
  command(:yoda){
    call do |*args|
      phrase = args.join(' ').strip
      url = 'http://www.yodaspeak.co.uk/index.php'
      error = nil

      if phrase.empty?
        phrase = most_recent_comment
      end

      if phrase
        agent = Mechanize.new
        agent.open_timeout = 240
        agent.read_timeout = 240

        catch(:done) do
          2.times do
            begin
              page = agent.get(url)

              form = page.forms.detect{|form| form.fields.detect{|field| field.name == 'YodaMe'}}

              form['YodaMe'] = phrase

              result = form.submit

              yoda_speak = result.search('textarea[name=YodaSpeak]').first.text

              speak("Yoda: #{ yoda_speak }")
              throw(:done)
            rescue Object
              next
            end
          end
        end
      end
    end
  }

##
#
  command(:poop){
    setup{ require "google-search" }

    call do |*args|
      images = Google::Search::Image.new(:query => 'poop', :image_size => :large)
      images = images.map{|result| result.uri}.uniq.sort_by{ rand }
      speak(msg = "coffee anyone?")
      speak(msg = images.sample)
    end
  }
}

