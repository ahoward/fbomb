## fbomb.gemspec
#

Gem::Specification::new do |spec|
  spec.name = "fbomb"
  spec.version = "0.4.2"
  spec.platform = Gem::Platform::RUBY
  spec.summary = "fbomb"
  spec.description = "description: fbomb kicks the ass"

  spec.files =
["Rakefile", "fbomb.gemspec", "lib", "lib/fbomb.rb"]

  spec.executables = []
  
  spec.require_path = "lib"

  spec.test_files = nil

  
    spec.add_dependency(*["tinder", "~> 1.4.3"])
  
    spec.add_dependency(*["main", "~> 4.7.3"])
  

  spec.extensions.push(*[])

  spec.rubyforge_project = "codeforpeople"
  spec.author = "Ara T. Howard"
  spec.email = "ara.t.howard@gmail.com"
  spec.homepage = "https://github.com/ahoward/fbomb"
end
