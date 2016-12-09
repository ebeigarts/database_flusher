# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'database_flusher/version'

Gem::Specification.new do |spec|
  spec.name          = "database_flusher"
  spec.version       = DatabaseFlusher::VERSION
  spec.authors       = ["Edgars Beigarts"]
  spec.email         = ["edgars.beigarts@gmail.com"]

  spec.summary       = %q{super-fast database cleaner}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/ebeigarts/database_flusher"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
