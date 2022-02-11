lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/android_sdk_update/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-android_sdk_update'
  spec.version       = Fastlane::AndroidSdkUpdate::VERSION
  spec.authors       = ['Philipp Burgk', 'Michael Ruhl']
  spec.email         = ['philipp.burgk@novatec-gmbh.de', 'michael.ruhl@novatec-gmbh.de']

  spec.summary       = 'Install required Android-SDK packages'
  spec.homepage      = "https://github.com/NovaTecConsulting/fastlane-plugin-android_sdk_update"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'fastlane-plugin-brew', '~> 0.1.1'
  spec.add_dependency 'java-properties', '~> 0.3.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'fastlane', '>= 2.91.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
end
