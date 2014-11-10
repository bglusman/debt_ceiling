require 'coveralls'
Coveralls.wear!
RSpec.configure do |config|
  config.before { allow($stdout).to receive(:puts) }
  config.after(:each) { DebtCeiling.configure {|c| c.debt_ceiling = nil; c.reduction_target = nil; c.reduction_date = nil } }
end
