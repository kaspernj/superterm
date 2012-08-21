# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{superterm}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kasper Johansen"]
  s.date = %q{2012-08-21}
  s.default_executable = %q{superterm.rb}
  s.description = %q{A terminal that focuses on remote control for various events.}
  s.email = %q{k@spernj.org}
  s.executables = ["superterm.rb"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rspec",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "bin/superterm.rb",
    "glade/win_main.glade",
    "gui/win_main.rb",
    "lib/superterm.rb",
    "lib/superterm_gui.rb",
    "lib/superterm_unix_socket.rb",
    "spec/spec_helper.rb",
    "spec/superterm_spec.rb"
  ]
  s.homepage = %q{http://github.com/kaspernj/superterm}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Got tired of various terminals that didnt work as I wanted them to.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<gtk2>, [">= 0"])
      s.add_runtime_dependency(%q<vte>, [">= 0"])
      s.add_runtime_dependency(%q<gettext>, [">= 0"])
      s.add_runtime_dependency(%q<sqlite3>, [">= 0"])
      s.add_runtime_dependency(%q<knjrbfw>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.8.0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, [">= 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.4"])
    else
      s.add_dependency(%q<gtk2>, [">= 0"])
      s.add_dependency(%q<vte>, [">= 0"])
      s.add_dependency(%q<gettext>, [">= 0"])
      s.add_dependency(%q<sqlite3>, [">= 0"])
      s.add_dependency(%q<knjrbfw>, [">= 0"])
      s.add_dependency(%q<rspec>, ["~> 2.8.0"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, [">= 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.4"])
    end
  else
    s.add_dependency(%q<gtk2>, [">= 0"])
    s.add_dependency(%q<vte>, [">= 0"])
    s.add_dependency(%q<gettext>, [">= 0"])
    s.add_dependency(%q<sqlite3>, [">= 0"])
    s.add_dependency(%q<knjrbfw>, [">= 0"])
    s.add_dependency(%q<rspec>, ["~> 2.8.0"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, [">= 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.4"])
  end
end

