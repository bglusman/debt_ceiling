module DebtCeiling
  class Debt
    DoNotWhitelistAndBlacklistSimulateneously = Class.new(StandardError)

    attr_reader :file_attributes, :path, :analysed_module, :module_name,
                :linecount, :source_code, :rating
    attr_accessor :debt_amount
    def initialize(file_attributes)
      @file_attributes  = file_attributes
      @path             = file_attributes.path
      @analysed_module  = file_attributes.analysed_module
      @module_name      = file_attributes.name
      @linecount        = file_attributes.linecount
      @source_code      = file_attributes.source_code
      @rating           = analysed_module.rating
      default_measure_debt if valid_debt?
    end

    def default_measure_debt
      cost = public_send(:measure_debt) if self.respond_to?(:measure_debt)

      unless cost
        cost = public_send(:augment_debt) if respond_to?(:augment_debt)
        cost = cost.to_i
        letter_grade = rating.to_s.downcase
        cost_per_line = DebtCeiling.public_send("#{letter_grade}_current_cost_per_line")
        cost += file_attributes.linecount * cost_per_line
        cost += debt_from_source_code_rules
      end
      self.debt_amount = cost
    end

    def debt_from_source_code_rules
      text_match_debt('TODO', DebtCeiling.current_cost_per_todo) +
      manual_callout_debt +
      DebtCeiling.deprecated_reference_pairs.map do|string, value|
        text_match_debt(string, value.to_i)
      end.reduce(&:+).to_i
    end

    def text_match_debt(string, cost)
      source_code.scan(string).count * cost
    end

    def manual_callout_debt
      DebtCeiling.manual_callouts.reduce(0) do |memo, callout|
        memo + source_code.each_line.reduce(0) do |accum, line|
          match_data = line.match(Regexp.new(callout + '.*'))
          string = match_data.to_s.split(callout).last
          amount = string.match(/\d+/).to_s if string
          accum + amount.to_i
        end
      end
    end

    def valid_debt?
      black_empty = DebtCeiling.blacklist.empty?
      white_empty = DebtCeiling.whitelist.empty?
      fail DoNotWhitelistAndBlacklistSimulateneously if !black_empty && !white_empty
      (black_empty && white_empty) ||
      (black_empty && self.class.whitelist_includes?(self)) ||
      (white_empty && !self.class.blacklist_includes?(self))
    end

    def self.whitelist_includes?(debt)
      DebtCeiling.whitelist.find { |filename| filename.match debt.path }
    end

    def self.blacklist_includes?(debt)
      DebtCeiling.blacklist.find { |filename| filename.match debt.path }
    end

    def name
      file_attributes.analysed_module.name || path.to_s.split('/').last
    end

    def to_i
      debt_amount.to_i
    end

    def +(other)
      to_i + other.to_i
    end
  end
end
