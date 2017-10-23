require 'spec_helper'
require 'debt_ceiling'

describe DebtCeiling do
  let(:fake_audit) { double(DebtCeiling::Audit) }
  before(:each) { allow(DebtCeiling::Audit).to receive(:new).and_return(fake_audit)}

  it 'has failing exit status when debt_ceiling is exceeded' do
    DebtCeiling.configure {|c| c.debt_ceiling = 0 }
    expect(DebtCeiling.debt_ceiling).to eq(0)
    allow(fake_audit).to receive(:fail_test)
    DebtCeiling.audit('.', preconfigured: true)
  end

  it 'has failing exit status when target debt reduction is missed' do
    DebtCeiling.configure {|c| c.reduction_target =0; c.reduction_date =  Time.now.to_s }
    expect(DebtCeiling.debt_ceiling).to eq(nil)
    allow(fake_audit).to receive(:fail_test)
    DebtCeiling.audit('.', preconfigured: true)
  end

  it 'has failing exit status when max debt per module is exceeded' do
    DebtCeiling.configure {|c| c.max_debt_per_module =5 }
    expect(DebtCeiling.debt_ceiling).to eq(nil)
    allow(fake_audit).to receive(:fail_test)
    DebtCeiling.audit('.', preconfigured: true)
  end

  it 'has no failing exit status when in warn only mode' do
    DebtCeiling.configure {|c| c.max_debt_per_module =5 }
    expect(DebtCeiling.debt_ceiling).to eq(nil)
    allow(fake_audit).to receive(:failed_condition?).at_least(:once).and_return(true)
    expect(fake_audit).not_to receive(:fail_test)
    DebtCeiling.audit('.', preconfigured: true, warn_only: true)
  end

end
