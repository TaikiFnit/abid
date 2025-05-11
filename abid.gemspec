# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'abid/version'

Gem::Specification.new do |spec|
  spec.name          = 'abid'
  spec.version       = Abid::VERSION
  spec.authors       = ['Hikaru Ojima']
  spec.email         = ['amijo4rihaku@gmail.com']

  spec.summary       = 'Abid is a simple Workflow Engine based on Rake.'
  spec.description   = 'Abid is a simple Workflow Engine based on Rake.'
  spec.homepage      = 'https://github.com/ojima-h/abid'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|sample)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.0.0'

  spec.add_development_dependency 'bundler', '~> 2.4'
  spec.add_development_dependency 'minitest', '~> 5.20'
  spec.add_development_dependency 'pry-byebug', '~> 3.10'
  spec.add_development_dependency 'yard', '~> 0.9'
  spec.add_development_dependency 'ruby-lsp', '~> 0.15.0'

  spec.add_dependency 'rake', '~> 13.0'
  spec.add_dependency 'concurrent-ruby-ext', '~> 1.2'
  spec.add_dependency 'sequel', '~> 5.76'
  spec.add_dependency 'sqlite3', '~> 1.7'
  spec.add_dependency 'thor', '~> 1.3'
  spec.add_dependency 'logger', '~> 1.6'
end
