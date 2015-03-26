require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start
require 'coveralls'
Coveralls.wear!

RSpec.configure do |config|
  config.before { allow($stdout).to receive(:puts) }
  config.after(:each) { DebtCeiling.configure {|c| c.debt_ceiling = nil; c.reduction_target = nil; c.reduction_date = nil } ; DebtCeiling.clear }
  config.after(:all) do
    DebtCeiling.configure do |c|
      c.whitelist = %w(app lib)
      c.max_debt_per_module = 150
      c.debt_ceiling = 250
    end
    DebtCeiling.calculate('.')
  end
end
