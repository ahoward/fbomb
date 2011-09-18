## fbomb.gemspec
#

Gem::Specification::new do |spec|
  spec.name = "fbomb"
  spec.version = "1.0.0"
  spec.platform = Gem::Platform::RUBY
  spec.summary = "fbomb"
  spec.description = "description: fbomb kicks the ass"

  spec.files =
["README",
 "Rakefile",
 "bin",
 "bin/fbomb",
 "fbomb.gemspec",
 "lib",
 "lib/fbomb",
 "lib/fbomb.rb",
 "lib/fbomb/campfire.rb",
 "lib/fbomb/command.rb",
 "lib/fbomb/commands",
 "lib/fbomb/commands/builtin.rb",
 "lib/fbomb/commands/system.rb",
 "lib/fbomb/util.rb"]

  spec.executables = ["fbomb"]
  
  spec.require_path = "lib"

  spec.test_files = nil

  
    spec.add_dependency(*["tinder", "~> 1.7.0"])
  
    spec.add_dependency(*["main", "~> 4.7.6"])
  
    spec.add_dependency(*["fukung", "~> 1.1.0"])
  
    spec.add_dependency(*["yajl-ruby", "~> 0.8.3"])
  

  spec.extensions.push(*[])

  spec.rubyforge_project = "codeforpeople"
  spec.author = "Ara T. Howard"
  spec.email = "ara.t.howard@gmail.com"
  spec.homepage = "https://github.com/ahoward/fbomb"
end
