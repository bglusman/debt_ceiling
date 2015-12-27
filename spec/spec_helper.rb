require 'coveralls'
require 'pry'
Coveralls.wear!

RSpec.configure do |config|
  config.before { allow($stdout).to receive(:puts) }
  config.after(:all) { DebtCeiling.audit unless ENV['SKIP'] }
end
