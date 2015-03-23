module DebtCeiling
  class ExplicitAssignedDebt < Debt

    private
    def_delegator :file_attributes, :source_code

    def default_measure_debt
      external_augmented_debt +
      debt_from_source_code_rules
    end

    def debt_from_source_code_rules
      manual_callout_debt +
      text_match_debt('TODO', DebtCeiling.cost_per_todo) +
      deprecated_reference_debt
    end

    def text_match_debt(string, cost)
      source_code.scan(string).count * cost.to_i
    end

    def manual_callout_debt
      DebtCeiling.manual_callouts.reduce(0) do |sum, callout|
        sum + debt_from_callout(callout)
      end
    end

    def deprecated_reference_debt
      DebtCeiling.deprecated_reference_pairs
        .reduce(0) {|accum, (string, value)| accum + text_match_debt(string, value.to_i) }
    end

    def debt_from_callout(callout)
      source_code.each_line.reduce(0) do |sum, line|
        match_data = line.match(Regexp.new(callout + '.*'))
        string = match_data.to_s.split(callout).last
        amount = string.match(/\d+/).to_s if string
        sum + amount.to_i
      end
    end
  end
end