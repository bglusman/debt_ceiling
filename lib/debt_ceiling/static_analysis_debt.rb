module DebtCeiling
  class StaticAnalysisDebt < Debt
    def_delegators :non_grade_scoring, :complexity_multiplier, :duplication_multiplier, :smells_multiplier,
                   :method_count_multiplier, :ideal_max_line_count, :cost_per_line_over_ideal
    def_delegators :file_attributes, :path, :analysed_module, :module_name, :linecount
    def_delegator :analysed_module, :rating

    def internal_measure_debt
      DebtCeiling.grade_points[letter_grade] + cost_from_non_grade_scoring
    end

    def cost_from_non_grade_scoring
      flog_flay_debt + method_count_debt + smells_debt + line_count_debt
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
      DebtCeiling #it has delegators assigned on it
    end

  end
end