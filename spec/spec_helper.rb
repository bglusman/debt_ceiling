require 'coveralls'
require 'pry'
Coveralls.wear!

RSpec.configure do |config|
  config.before { allow($stdout).to receive(:puts) }
  at_exit { DebtCeiling.audit unless ENV['SKIP'] }
end
