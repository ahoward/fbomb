FBomb {
  command(:help) {
    call do |*args|
      sections = []
      Command.table.each do |path, command|
        next if path == '/help'
        help = command.help || path
        chunk = [path, Util.indent(help) + "\n"]
        sections.push(chunk)
      end
      sections.sort!{|a, b| a.first <=> b.first}
      sections.push(["/help", Util.indent("this message") + "\n"])
      msg = sections.join("\n")
      paste(msg) unless msg.strip.empty?
    end
  }

  command(:reload){
    help 'reload fbomb commands'
    
    call do |*args|
      Thread.critical = true
      table = FBomb::Command.table

      begin
        FBomb::Command.table = FBomb::Command::Table.new
        FBomb::Command.load(Command.command_paths)
        speak('locked and loaded.')
      rescue Object => e
        #msg = "#{ e.message }(#{ e.class })\n#{ Array(e.backtrace).join(10.chr) }"
        #speak(msg)
        FBomb::Command.table = table
      ensure
        Thread.critical = false
      end
    end
  }

  command(:fbomb) {
    call {
      urls = %w(
        http://s3.amazonaws.com/drawohara.com.mp3/tom_jones_sex_bomb_dance_remix.mp3
        http://4.bp.blogspot.com/-K7nKv-g9WyQ/Thb7Jqw-YoI/AAAAAAAABeo/e0AWFySD_GY/s1600/Tom+Jones+2.jpg
        http://www.fitceleb.com/files/tom_jones.jpg
      )
      speak(urls.sort_by{ rand }.first)
    }
  }
}
