# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{xibdiff}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Igor Sales"]
  s.date = %q{2010-07-04}
  s.description = %q{xibdiff is a ruby command-line tool to diff two nib or xib files.}
  s.email = ["self@igorsales.ca"]
  s.extra_rdoc_files = ["README.txt"]
  s.files = ["README.txt", "Rakefile", "lib/XibDiffLogger.rb", "lib/XibDiffObjectAdditions.rb", "lib/XibDiffObjectComparison.rb", "lib/XibDiffXibComparison.rb", "bin/xibdiff"]
  s.homepage = %q{http://github.com/igorsales/xibdiff}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{xibdiff}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{XIB/NIB diff tool for Mac OS X}
end
