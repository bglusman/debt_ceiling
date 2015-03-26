module DebtCeiling
  class Accounting
    DebtCeilingExceeded  = Class.new(StandardError)
    TargetDeadlineMissed = Class.new(StandardError)
    extend Forwardable
    attr_reader :result, :path, :debts, :total_debt, :max_debt

    def initialize(path, opts = {})
      @path = path
      calc_debt_for_modules(construct_rubycritic_modules(path))
    end

    def calc_debt_for_modules(analysed_modules)
      @debts      = analysed_modules.map {|mod| Debt.new(FileAttributes.new(mod)) }
      @total_debt = get_total_debt
      @max_debt   = get_max_debt
    end

    def print_results
      puts <<-RESULTS
        Current total tech debt: #{total_debt}
        Largest source of debt is: #{max_debt.name} at #{max_debt.to_i}
        The rubycritic grade for that debt is: #{max_debt.letter_grade}
        The flog complexity for that debt is: #{max_debt_module.complexity}
        Flay suspects #{max_debt_module.duplication.to_i} areas of code duplication
        There are #{method_count} methods and #{smell_count} smell(s) from reek.
        The file is #{max_debt.linecount} lines long.
      RESULTS
    end

    def get_max_debt
      debts.max_by(&:to_i)
    end

    def get_total_debt
      debts.map(&:to_i).reduce(:+)
    end

    def max_debt_module
      max_debt.analysed_module
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
