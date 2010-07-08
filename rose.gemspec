# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rose}
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Henry Hsu"]
  s.date = %q{2010-07-07}
  s.description = %q{A slick Ruby DSL for reporting.}
  s.email = %q{henry@qlane.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.markdown"
  ]
  s.files = [
    ".autotest",
     ".document",
     ".gitignore",
     "LICENSE",
     "README.markdown",
     "Rakefile",
     "VERSION",
     "features/rose.feature",
     "features/step_definitions/rose_steps.rb",
     "features/support/env.rb",
     "lib/rose.rb",
     "lib/rose/active_record.rb",
     "lib/rose/attribute.rb",
     "lib/rose/core_extensions.rb",
     "lib/rose/object.rb",
     "lib/rose/proxy.rb",
     "lib/rose/ruport.rb",
     "lib/rose/seedling.rb",
     "lib/rose/shell.rb",
     "rose.gemspec",
     "spec/core_extensions_spec.rb",
     "spec/db/schema.rb",
     "spec/examples/update_flowers.csv",
     "spec/examples/update_posts.csv",
     "spec/rose/active_record_spec.rb",
     "spec/rose/object_spec.rb",
     "spec/rose_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/hsume2/rose}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Reporting like a spring rose, rows and rows of it}
  s.test_files = [
    "spec/core_extensions_spec.rb",
     "spec/db/schema.rb",
     "spec/rose/active_record_spec.rb",
     "spec/rose/object_spec.rb",
     "spec/rose_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ruport>, [">= 1.6.3"])
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_development_dependency(%q<yard>, [">= 0"])
      s.add_development_dependency(%q<cucumber>, [">= 0"])
    else
      s.add_dependency(%q<ruport>, [">= 1.6.3"])
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_dependency(%q<yard>, [">= 0"])
      s.add_dependency(%q<cucumber>, [">= 0"])
    end
  else
    s.add_dependency(%q<ruport>, [">= 1.6.3"])
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
    s.add_dependency(%q<yard>, [">= 0"])
    s.add_dependency(%q<cucumber>, [">= 0"])
  end
end

