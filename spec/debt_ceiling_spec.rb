require 'spec_helper'
require 'debt_ceiling'

describe DebtCeiling do
  it 'has failing exit status when debt_ceiling is exceeded' do
    DebtCeiling.configure {|c| c.debt_ceiling = 0 }
    expect(DebtCeiling.debt_ceiling).to eq(0)
    allow(DebtCeiling).to receive(:fail_test)
    DebtCeiling.calculate('.', preconfigured: true)
    expect(DebtCeiling).to have_received(:fail_test)
  end

  it 'has failing exit status when target debt reduction is missed' do
    DebtCeiling.configure {|c| c.reduction_target =0; c.reduction_date =  Time.now.to_s }
    expect(DebtCeiling.debt_ceiling).to eq(nil)
    allow(DebtCeiling).to receive(:fail_test)
    DebtCeiling.calculate('.', preconfigured: true)
    expect(DebtCeiling).to have_received(:fail_test)
  end

  it 'has failing exit status when max debt per modile is exceeded' do
    DebtCeiling.configure {|c| c.max_debt_per_module =5 }
    expect(DebtCeiling.debt_ceiling).to eq(nil)
    allow(DebtCeiling).to receive(:fail_test)
    DebtCeiling.calculate('.', preconfigured: true)
    expect(DebtCeiling).to have_received(:fail_test)
  end

  it 'returns quantity of total debt' do
    expect(DebtCeiling.calculate('.')).to be > 5 # arbitrary non-zero amount
  end

  it 'adds debt for todos with specified value' do
    todo_amount = 50
    DebtCeiling.configure {|c| c.cost_per_todo = todo_amount }
    expect(DebtCeiling.calculate('spec/support/todo_example.rb')).to be todo_amount
  end

  it 'allows manual debt with TECH DEBT comment' do
    expect(DebtCeiling.calculate('spec/support/manual_example.rb')).to be 100 # hardcoded in example file
  end

  it 'allows manual debt with arbitrarily defined comment' do
    DebtCeiling.configure {|c| c.manual_callouts += ['REFACTOR'] }
    expect(DebtCeiling.calculate('spec/support/manual_example.rb')).to be 150 # hardcoded in example file
  end

  it 'assigns debt for file length over ideal file size' do
    DebtCeiling.configure {|c| c.ideal_max_line_count = 10; c.cost_per_line_over_ideal = 100 }
    expect(DebtCeiling.calculate('spec/support/long_file_example.rb', preconfigured: true)).to be 300 # hardcoded 13 lines long example file
  end

end
