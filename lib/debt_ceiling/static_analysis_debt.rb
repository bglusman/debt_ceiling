module DebtCeiling
  class StaticAnalysisDebt
    extend Forwardable
    include CommonMethods
    def_delegators :configuration,
                   :complexity_multiplier, :duplication_multiplier, :smells_multiplier,
                   :grade_points, :method_count_multiplier, :ideal_max_line_count,
                   :cost_per_line_over_ideal

    attr_reader :analysed_module
    def_delegators :analysed_module,
                   :smells, :methods_count, :complexity, :duplication, :rating

    def_delegators :file_attributes,
                  :linecount, :path

    def_delegator  :debt_amount, :to_i


    def initialize(file_attributes)
      @file_attributes  = file_attributes
      @analysed_module  = RubyCritic::AnalysersRunner.new(Array(path)).run.first
      # require 'pry'; binding.pry
      @debt_amount      = cost_from_static_analysis_points if analysed_module
    end

    private

    attr_reader :file_attributes, :debt_amount

    def cost_from_static_analysis_points
      grade_points[letter_grade] + cost_from_non_grade_scoring
    end

    def cost_from_non_grade_scoring
      flog_flay_debt + method_count_debt + smells_debt + line_count_debt
    end

    def letter_grade
      rating.to_s.downcase.to_sym
    end

    def smells_debt
      smells.map(&:cost).inject(0, :+) * smells_multiplier
    end

    def method_count_debt
      methods_count * method_count_multiplier
    end

    def flog_flay_debt
      complexity *  complexity_multiplier +
      duplication * duplication_multiplier
    end

    def line_count_debt
      excess_lines = linecount - ideal_max_line_count
      excess_lines > 0 ? excess_lines * cost_per_line_over_ideal : 0
    end

  end
end