lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'xibit/version'

Gem::Specification.new do |gem|
  gem.name        = 'xibit'
  gem.version     = Xibit::VERSION
  gem.date        = '2013-10-01'
  gem.summary     = "Serialization for REST /JSON APIs"
  gem.description = "Blah Blah Blah"
  gem.authors     = ["Adam Simpson"]
  gem.email       = 'ad_simpson@somewhere.com'
  gem.files       = Dir.glob("{lib}/**/*")
  gem.require_path = 'lib'
  gem.homepage    =
    'http://rubygems.org/gems/xibit'
  gem.license       = 'MIT'
  
  gem.add_dependency 'will_paginate', '~> 3.0'
end