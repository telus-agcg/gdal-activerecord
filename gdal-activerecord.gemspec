# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gdal/activerecord/version'

Gem::Specification.new do |spec|
  spec.name          = 'gdal-activerecord'
  spec.version       = GDAL::ActiveRecord::VERSION
  spec.authors       = ['Steve Loveless']
  spec.email         = ['steve@agrian.com']
  spec.summary       = 'Use GDAL with PostGIS via ActiveRecord'
  spec.homepage      = 'https://bitbucket.org/agrian/gdal-activerecord'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'ffi-gdal', '>= 1.0.0.beta6'
  spec.add_dependency 'ffi-gdal-extensions'
  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'pg', '~> 0.11'
  spec.add_development_dependency 'rails', '~> 4.1.0'
  spec.add_development_dependency 'rake', '~> 10.0'
end
