# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "redis/orm/version"

Gem::Specification.new do |s|
  s.name        = "redis-orm"
  s.version     = Redis::ORM::VERSION
  s.authors     = ["Colin MacKenzie IV"]
  s.email       = ["sinisterchipmunk@gmail.com"]
  s.homepage    = "http://github.com/sinisterchipmunk/redis-orm"
  s.summary     = %q{Object-relational mapping for Redis}
  s.description = %q{The goal of this project is to provide ORM for Redis that feels very similar to ActiveRecord.}

  s.rubyforge_project = "redis-orm"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rspec',      '~> 2.6.0'
  s.add_development_dependency 'rake',       '~> 0.9.2'
  s.add_development_dependency 'bundler',    '~> 1.0.18'

  s.add_runtime_dependency 'redis',          '~> 2.2.2'
  s.add_runtime_dependency 'activemodel',    '~> 3.0.10'
end
