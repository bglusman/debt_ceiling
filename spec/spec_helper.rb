RSpec.configure do |config|
  config.before { allow($stdout).to receive(:puts) }
  config.after(:each) { DebtCeiling.set_debt_ceiling(nil); DebtCeiling.clear_reduction_targets }
end
