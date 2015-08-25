# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'eagle_search/version'

Gem::Specification.new do |spec|
  spec.name          = "eagle_search"
  spec.version       = EagleSearch::VERSION
  spec.authors       = ["Igor Belo"]
  spec.email         = ["igorcoura@gmail.com"]

  spec.summary       = %q{Rails Model integration for Elasticsearch.}
  spec.description   = %q{Rails Model integration for Elasticsearch.}
  spec.homepage      = "https://github.com/igorbelo/eagle_graph"
  spec.license       = "MIT"
  spec.files         = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "elasticsearch", "~> 1.0"
  spec.add_dependency "activerecord", "~> 4.2"

  spec.add_development_dependency "sqlite3", "~> 1.3"
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3"
end
