module DebtCeiling
  module CustomDebtAnalysis

    def external_measure_debt
      public_send(:measure_debt) if self.respond_to?(:measure_debt)
    end

    def external_augmented_debt
      (public_send(:augment_debt) if respond_to?(:augment_debt)).to_i
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

    def valid_debt?
      black_empty = DebtCeiling.blacklist.empty?
      white_empty = DebtCeiling.whitelist.empty?
      fail DoNotWhitelistAndBlacklistSimulateneously unless black_empty || white_empty
      (black_empty && white_empty) ||
      (black_empty && self.class.whitelist_includes?(self)) ||
      (white_empty && !self.class.blacklist_includes?(self))
    end
  end
end