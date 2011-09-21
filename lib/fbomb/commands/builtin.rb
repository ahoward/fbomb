FBomb {

##
#
  command(:rhymeswith) {
    help 'show ryhming words'

    setup{ require 'cgi' }

    call do |*args|
      args.each do |arg|
        word = CGI.escape(arg.strip)
        url = "http://www.zachblume.com/apis/rhyme.php?format=xml&word=#{ word }"
        data = `curl --silent #{ url.inspect }`
        words = data.scan(%r|<word>([^<]*)</word>|).flatten
        msg = words.join(" ")
        speak(msg)
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
          Google::Search::Image.new(:query => query, :image_size => :icon).each do |result|
            msg << "#{ result.uri }\n"
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

  command(:designquote) {
    call do |*args|
      data = JSON.parse(`curl --silent 'http://quotesondesign.com/api/3.0/api-3.0.json'`)
      quote = data['quote']
      author = data['author']
      msg = quote + ' - ' + author
      speak(msg) if msg
    end
  }

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
}

