# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ff_danger/version'

Gem::Specification.new do |spec|
  spec.name          = 'ff_danger'
  spec.version       = FfDanger::VERSION
  spec.authors       = ['Tony Schaffert']
  spec.email         = ['tschaffert@forwardfinancing.com']

  spec.summary       = 'Dangerbot rules for FFs repos extracted into a Gem for reusability.'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/Ff/lib-danger'


  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.files.reject! { |file| file =~ /\.gem$/ }

  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'danger'
  spec.add_dependency 'git_diff_parser'
  spec.add_dependency 'parser'

  spec.add_development_dependency 'bundler', '>= 2.3'
  spec.add_development_dependency 'fuubar'
  spec.add_development_dependency 'package_cloud'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'thor'
end
