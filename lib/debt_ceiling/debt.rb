require 'forwardable'
module DebtCeiling
  class Debt
    extend Forwardable
    DoNotWhitelistAndBlacklistSimulateneously = Class.new(StandardError)

    attr_reader :file_attributes
    def_delegators :file_attributes, :path, :analysed_module, :module_name, :linecount, :source_code
    def_delegator :analysed_module, :rating
    attr_accessor :debt_amount
    def_delegator :debt_amount, :to_i

    def initialize(file_attributes)
      @file_attributes  = file_attributes
      default_measure_debt if valid_debt?
    end

    def default_measure_debt
      cost = public_send(:measure_debt) if self.respond_to?(:measure_debt)

      unless cost
        cost = public_send(:augment_debt) if respond_to?(:augment_debt)
        cost = cost.to_i
        letter_grade = rating.to_s.downcase
        cost_per_line = DebtCeiling.configuration.grade_points[letter_grade.to_sym]
        cost += file_attributes.linecount * cost_per_line
        cost += debt_from_source_code_rules
      end
      self.debt_amount = cost
    end

    def debt_from_source_code_rules
      manual_callout_debt +
      text_match_debt('TODO', DebtCeiling.cost_per_todo) +
      DebtCeiling.deprecated_reference_pairs
        .reduce(0) {|accum, (string, value)| accum + text_match_debt(string, value.to_i) }
    end

    def text_match_debt(string, cost)
      source_code.scan(string).count * cost.to_i
    end

    def manual_callout_debt
      DebtCeiling.manual_callouts.reduce(0) do |sum, callout|
        sum + debt_from_callout(callout)
      end
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

    def self.whitelist_includes?(debt)
      DebtCeiling.whitelist.find { |filename| debt.path.match filename }
    end

    def self.blacklist_includes?(debt)
      DebtCeiling.blacklist.find { |filename| debt.path.match filename }
    end

    def name
      file_attributes.analysed_module.name || path.to_s.split('/').last
    end

    def +(other)
      to_i + other.to_i
    end
  end
end
