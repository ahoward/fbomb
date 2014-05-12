## fbomb.gemspec
#

Gem::Specification::new do |spec|
  spec.name = "fbomb"
  spec.version = "2.0.0"
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
  
    spec.add_dependency(*["main", ">= 4.7.6"])
  
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
