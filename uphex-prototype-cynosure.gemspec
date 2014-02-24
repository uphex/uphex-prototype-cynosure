# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "uphex-prototype-cynosure"
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["sashee"]
  s.date = "2014-02-20"
  s.description = "Uphex Shiatsu"
  s.email = ["gsashee@gmail.com"]
  s.files = ["README.md", "Gemfile", "Rakefile", "spec/google_spec.rb","spec/twitter_spec.rb", "lib/uphex", "lib/uphex/prototype", "lib/uphex/prototype/cynosure", "lib/uphex/prototype/cynosure/version.rb", "lib/uphex/prototype/cynosure/shiatsu.rb", "lib/uphex/prototype/cynosure.rb"]
  s.homepage = ""
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.3"
  s.summary = "OAuth data fetcher"
  s.test_files = ["spec/google_spec.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.3"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_runtime_dependency(%q<oauth2>, [">= 0"])
      s.add_runtime_dependency(%q<legato>, [">= 0"])
      s.add_runtime_dependency(%q<twitter>, [">= 0"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.3"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<oauth2>, [">= 0"])
      s.add_dependency(%q<legato>, [">= 0"])
      s.add_dependency(%q<twitter>, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.3"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<oauth2>, [">= 0"])
    s.add_dependency(%q<legato>, [">= 0"])
    s.add_dependency(%q<twitter>, [">= 0"])
  end
end
