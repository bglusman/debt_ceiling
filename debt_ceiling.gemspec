# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)
require 'debt_ceiling/version'

Gem::Specification.new do |s|
  s.name        = 'debt_ceiling'
  s.version     = DebtCeiling::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Brian Glusman']
  s.email       = ['brian@stellaservice.com']
  s.homepage    = 'https://github.com/bglusman/debt_ceiling'
  s.summary     = 'DebtCeiling helps you track Tech Debt'
  s.rubyforge_project = 'debt_ceiling'

  s.description = <<-DESC
    Get a grip on your technical debt
  DESC

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_runtime_dependency 'rubycritic', '~> 3.0'
  s.add_runtime_dependency 'chronic', '~> 0.10'
  s.add_runtime_dependency 'sparkr', '~> 0.4.1'
  s.add_runtime_dependency 'configurations', '~> 2.0'
end
