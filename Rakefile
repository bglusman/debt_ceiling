#!/usr/bin/env rake

if Regexp.new('RUBYARCHDIR') === ARGV[0]
  require_relative "lib/debt_ceiling/post_install"
  DebtCeiling::PostInstall.new(ARGV[0])
end

task :default => 'test'
task :test do
  sh "ruby test/debt_ceiling_test.rb"
end
