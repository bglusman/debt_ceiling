require "spec_helper"
require "debt_ceiling"

describe DebtCeiling do
  it "has failing exit status when debt_ceiling is exceeded" do
    DebtCeiling.set_debt_ceiling(0)
    expect(DebtCeiling.ceiling_amount).to eq(0)
    expect { DebtCeiling.calculate('.') }.to raise_error
  end

  it "has failing exit status when target debt reduction is missed" do
    DebtCeiling.debt_reduction_target_and_date(0, Time.now.to_s)
    expect(DebtCeiling.ceiling_amount).to eq(nil)
    expect { DebtCeiling.calculate('.') }.to raise_error
  end

  it "returns quantity of total debt" do
    expect(DebtCeiling.calculate('.')).to be > 5 #arbitrary non-zero amount
  end

  it "adds debt for todos with specified value" do
    todo_amount = 50
    DebtCeiling.cost_per_todo(todo_amount)
    expect(DebtCeiling.calculate('spec/support/todo_example.rb')).to be todo_amount
  end

  it "allows manual debt with TECH DEBT comment" do
    expect(DebtCeiling.calculate('spec/support/manual_example.rb')).to be 100 #hardcoded in example file
  end

  it "allows manual debt with arbitrarily defined comment" do
    DebtCeiling.explicit_comment_callouts('REFACTOR')
    expect(DebtCeiling.calculate('spec/support/manual_example.rb')).to be 150 #hardcoded in example file
  end

end