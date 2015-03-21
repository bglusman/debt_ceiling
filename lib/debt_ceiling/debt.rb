require 'forwardable'
module DebtCeiling
  class Debt
    extend Forwardable
    include CustomDebtAnalysis
    DoNotWhitelistAndBlacklistSimulateneously = Class.new(StandardError)

    def_delegators :file_attributes, :path, :analysed_module, :module_name, :linecount, :source_code
    def_delegators :non_grade_scoring, :complexity_multiplier, :duplication_multiplier, :smells_multiplier,
                   :method_count_multiplier, :ideal_max_line_count, :cost_per_line_over_ideal
    def_delegator :analysed_module, :rating
    attr_accessor :debt_amount
    def_delegator :debt_amount, :to_i

    def initialize(file_attributes)
      @file_attributes  = file_attributes
      default_measure_debt if valid_debt?
    end

    def name
      file_attributes.analysed_module.name || path.to_s.split('/').last
    end

    def +(other)
      to_i + other.to_i
    end

    def letter_grade
      rating.to_s.downcase.to_sym
    end

    private

    attr_reader :file_attributes

    def default_measure_debt
      self.debt_amount = external_measure_debt || internal_measure_debt
    end

    def internal_measure_debt
      external_augmented_debt +
      cost_from_static_analysis_points +
      debt_from_source_code_rules
    end

    def cost_from_static_analysis_points
      DebtCeiling.grade_points[letter_grade] +
      cost_from_non_grade_scoring
    end

    def cost_from_non_grade_scoring
      flog_flay_debt +
      method_count_debt +
      smells_debt +
      line_count_debt
    end

    def smells_debt
      analysed_module.smells.map(&:cost).inject(0, :+) * smells_multiplier
    end

    def method_count_debt
      analysed_module.methods_count * method_count_multiplier
    end

    def flog_flay_debt
      analysed_module.complexity *  complexity_multiplier +
      analysed_module.duplication * duplication_multiplier
    end

    def line_count_debt
      excess_lines = linecount - ideal_max_line_count
      excess_lines > 0 ? excess_lines * cost_per_line_over_ideal : 0
    end

    def non_grade_scoring
      DebtCeiling
    end

    def self.whitelist_includes?(debt)
      DebtCeiling.whitelist.find { |filename| debt.path.match filename }
    end

    def self.blacklist_includes?(debt)
      DebtCeiling.blacklist.find { |filename| debt.path.match filename }
    end

  end
end
