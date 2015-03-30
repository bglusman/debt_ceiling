require 'spec_helper'
require 'debt_ceiling'

describe DebtCeiling do
  it 'has failing exit status when debt_ceiling is exceeded' do
    DebtCeiling.configure {|c| c.debt_ceiling = 0 }
    expect(DebtCeiling.debt_ceiling).to eq(0)
    expect_any_instance_of(DebtCeiling::Audit).to receive(:fail_test)
    DebtCeiling.audit('.', preconfigured: true)
  end

  it 'has failing exit status when target debt reduction is missed' do
    DebtCeiling.configure {|c| c.reduction_target =0; c.reduction_date =  Time.now.to_s }
    expect(DebtCeiling.debt_ceiling).to eq(nil)
    expect_any_instance_of(DebtCeiling::Audit).to receive(:fail_test)
    DebtCeiling.audit('.', preconfigured: true)
  end

  it 'has failing exit status when max debt per modile is exceeded' do
    DebtCeiling.configure {|c| c.max_debt_per_module =5 }
    expect(DebtCeiling.debt_ceiling).to eq(nil)
    expect_any_instance_of(DebtCeiling::Audit).to receive(:fail_test)
    DebtCeiling.audit('.', preconfigured: true)
  end

  it 'returns quantity of total debt' do
    expect(DebtCeiling.audit('.').total_debt).to be > 5 # arbitrary non-zero amount
  end

  it 'adds debt for todos with specified value' do
    todo_amount = 50
    DebtCeiling.configure {|c| c.cost_per_todo = todo_amount }
    expect(DebtCeiling.audit('spec/support/todo_example.rb', preconfigured: true).total_debt).to be todo_amount
  end

  it 'allows manual debt with TECH DEBT comment' do
    expect(DebtCeiling.audit('spec/support/manual_example.rb', preconfigured: true).total_debt).to be 100 # hardcoded in example file
  end

  it 'allows manual debt with arbitrarily defined comment' do
    DebtCeiling.configure {|c| c.manual_callouts += ['REFACTOR'] }
    expect(DebtCeiling.audit('spec/support/manual_example.rb', preconfigured: true).total_debt).to be 150 # hardcoded in example file
  end

  it 'assigns debt for file length over ideal file size' do
    DebtCeiling.configure {|c| c.ideal_max_line_count = 10; c.cost_per_line_over_ideal = 100 }
    expect(DebtCeiling.audit('spec/support/long_file_example.rb', preconfigured: true).total_debt).to be 300 # hardcoded 13 lines long example file
  end

end
