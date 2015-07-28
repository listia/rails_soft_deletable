# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails_soft_deletable/version'

Gem::Specification.new do |spec|
  spec.name          = "rails_soft_deletable"
  spec.version       = RailsSoftDeletable::VERSION
  spec.authors       = ["Quan Nguyen", "Ngan Pham"]
  spec.email         = ["quan@listia.com", "ngan@listia.com"]
  spec.description   = %q{Soft deletable for ActiveRecord on Rails 3+.}
  spec.summary       = %q{Soft deletable for ActiveRecord on Rails 3+}
  spec.homepage      = "https://github.com/listia/rails_soft_deletable"
  spec.license       = "MIT"

  spec.files         = Dir["{lib,spec}/**/*"].select { |f| File.file?(f) } +
                         %w(LICENSE.txt Rakefile README.md)
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 3.2", "< 4.2"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec-rails", "~> 3.3", ">= 3.3.0"
  spec.add_development_dependency "byebug", "~> 4.0.5"
  spec.add_development_dependency "timecop"
  spec.add_development_dependency "sqlite3"
  # RAILS: This gem can be removed in Rails 5.
  spec.add_development_dependency "test_after_commit", "~> 0.4.1"
end
