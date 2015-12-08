## fbomb.gemspec
#

Gem::Specification::new do |spec|
  spec.name = "fbomb"
  spec.version = "4.1.0"
  spec.platform = Gem::Platform::RUBY
  spec.summary = "fbomb"
  spec.description = "description: fbomb kicks the ass"
  spec.license = "Ruby"

  spec.files =
["Gemfile",
 "Gemfile.lock",
 "README.md",
 "Rakefile",
 "bin",
 "bin/fbomb",
 "fbomb.gemspec",
 "images",
 "images/michael",
 "images/michael/Aviation-Cat-Halloween-Costume.jpg.jpg",
 "images/michael/Bumblebee-Cat-Halloween-Costume.jpg.jpg",
 "images/michael/Burger-Cat-Halloween-Costume.jpg.jpg",
 "images/michael/Business-Cat-Halloween-Costume.png.png",
 "images/michael/Cat-Batman-Halloween-Costume.jpg.jpg",
 "images/michael/Cat-Dressed-as-a-Bunny-For-Halloween.jpg.jpg",
 "images/michael/Cat-in-the-Hat-Halloween-Costume.jpg.jpg",
 "images/michael/Fitness-Cat-Halloween-Costume.jpg.jpg",
 "images/michael/Froggy-Cat-Halloween-Costume.jpg.jpg",
 "images/michael/Harry-Potter-Cat-Halloween-Costume.jpg.jpg",
 "images/michael/Hello-Kitty-Cat-Halloween-Costume.jpg.jpg",
 "images/michael/Lion-Cat-Halloween-Costume.jpg.jpg",
 "images/michael/Little-Red-Riding-Cat-Halloween-Costume.jpg.jpg",
 "images/michael/Lobster-Cat-Halloween-Costume.png.png",
 "images/michael/Pirate-Cat-Halloween-Costume.jpg.jpg",
 "images/michael/Princess-Leia-Halloween-Cat-Costume.jpg.jpg",
 "images/michael/Pumpkin-Cat-Halloween-Costume.jpg-600x400.jpg",
 "images/michael/Pure-Bred-Cat-Halloween-Costume.jpg.jpg",
 "images/michael/Rice-Krispies-Treat-Cat.jpg.jpg",
 "images/michael/Scuba-Cat-Halloween-Costume.jpg.jpg",
 "images/michael/Spider-Cat-Halloween-Costume.jpg-600x427.jpg",
 "images/michael/Super-Mario-Cat-Halloween-Costume.png.png",
 "images/michael/Superman-Cat-Halloween-Costume.jpg-600x525.jpg",
 "images/michael/Sushi-Cat-Halloween-Costume2.jpg2.jpg",
 "images/michael/Taco-Cat-Halloween-Costume.jpg.jpg",
 "images/michael/Witch-Hat-Cat-Costume-For-Halloween.jpg.jpg",
 "images/michael/Yoda-Cat-Halloween-Costume.png.png",
 "images/planet",
 "images/planet/1dEzGbz.jpg",
 "images/planet/3aASzbv.jpg",
 "images/planet/BCfEwgl.jpg",
 "images/planet/EPbgqjy.jpg",
 "images/planet/FoiDgwc.jpg",
 "images/planet/HJiUPV2.jpg",
 "images/planet/KOcvGjw.jpg",
 "images/planet/L5n5lPK.jpg",
 "images/planet/MaGKipv.jpg",
 "images/planet/QVRALtz.jpg",
 "images/planet/W3fWkTZ.jpg",
 "images/planet/about.md",
 "images/planet/nWqdkF7.jpg",
 "images/planet/w41sv1T.jpg",
 "images/planet/xySa4GD.jpg",
 "images/planet/yzw8pOQ.jpg",
 "lib",
 "lib/fbomb",
 "lib/fbomb.rb",
 "lib/fbomb/campfire.rb",
 "lib/fbomb/command.rb",
 "lib/fbomb/commands",
 "lib/fbomb/commands/builtin.rb",
 "lib/fbomb/commands/system.rb",
 "lib/fbomb/flowdock.rb",
 "lib/fbomb/util.rb",
 "lib/fbomb/uuid.rb",
 "notes",
 "notes/ara.txt"]

  spec.executables = ["fbomb"]
  
  spec.require_path = "lib"

  spec.test_files = nil

  
    spec.add_dependency(*["flowdock", ">= 0.4.0"])
  
    spec.add_dependency(*["eventmachine", ">= 1.0.3"])
  
    spec.add_dependency(*["em-http-request", ">= 1.1.2"])
  
    spec.add_dependency(*["json", ">= 1.8.1"])
  
    spec.add_dependency(*["coerce", ">= 0.0.6"])
  
    spec.add_dependency(*["fukung", ">= 1.1.0"])
  
    spec.add_dependency(*["main", ">= 6.1.0"])
  
    spec.add_dependency(*["nokogiri", ">= 1.5.0"])
  
    spec.add_dependency(*["google-search", ">= 1.0.2"])
  
    spec.add_dependency(*["unidecode", ">= 1.0.0"])
  
    spec.add_dependency(*["systemu", ">= 2.3.0"])
  
    spec.add_dependency(*["pry", ">= 0.9.6.2"])
  
    spec.add_dependency(*["mechanize", ">= 2.7.3"])
  
    spec.add_dependency(*["mime-types", ">= 1.16"])
  

  spec.extensions.push(*[])

  spec.rubyforge_project = "codeforpeople"
  spec.author = "Ara T. Howard"
  spec.email = "ara.t.howard@gmail.com"
  spec.homepage = "https://github.com/ahoward/fbomb"
end
