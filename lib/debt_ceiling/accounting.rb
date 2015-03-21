module DebtCeiling
  class Accounting
    DebtCeilingExceeded  = Class.new(StandardError)
    TargetDeadlineMissed = Class.new(StandardError)
    class << self
      attr_reader :result, :path
      def calculate(path)
        @path = path
        print_results
        result
      end

      def result
        @result ||= construct_result
      end

      def clear
        @result = nil
      end

      def construct_result
        analysed_modules   = construct_rubycritic_modules(path)
        result_from_analysed_modules(analysed_modules)
      end

      def result_from_analysed_modules(analysed_modules)
        analysis            = OpenStruct.new
        analysis.debts      = analysed_modules.map {|mod| Debt.new(FileAttributes.new(mod)) }
        analysis.max_debt   = analysis.debts.max_by(&:to_i)
        analysis.total_debt = analysis.debts.map(&:to_i).reduce(:+)
        analysis
      end

      def print_results
        puts <<-RESULTS
          Current total tech debt: #{result.total_debt}
          Largest source of debt is: #{max_debt.name} at #{max_debt.to_i}
          The rubycritic grade for that debt is: #{max_debt.letter_grade}
          The flog complexity for that debt is: #{max_debt.analysed_module.complexity}
          Flay suspects #{max_debt.analysed_module.duplication.to_i} areas of code duplication
          There are #{method_count} methods and #{smell_count} smell(s) from reek
        RESULTS
      end

      def max_debt
        result.max_debt
      end

      def method_count
        max_debt.analysed_module.methods_count
      end

      def smell_count
        max_debt.analysed_module.smells.count
      end

      def construct_rubycritic_modules(path)
        Rubycritic.create(mode: :ci, format: :json, paths: Array(path)).critique
      end
    end
  end
end
