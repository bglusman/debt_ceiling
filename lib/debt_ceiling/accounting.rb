module DebtCeiling
  class Accounting
    DebtCeilingExceeded  = Class.new(StandardError)
    TargetDeadlineMissed = Class.new(StandardError)
    extend Forwardable
    attr_reader :result, :path, :debts, :total_debt, :max_debt

    def_delegator :max_debt, :analysed_module
    alias_method :max_module, :analysed_module
    def initialize(path)
      @path = path
      calc_debt_for_modules(construct_paths(path))
    end

    def calc_debt_for_modules(modules)
      @debts      = modules.map {|mod| Debt.new(FileAttributes.new(mod)) }
      @total_debt = get_total_debt
      @max_debt   = get_max_debt
    end

    def print_results
      puts <<-RESULTS
        Current total tech debt: #{total_debt}
        Largest source of debt is: #{max_debt.name} at #{max_debt.to_i}
        The rubycritic grade for that debt is: #{max_debt.letter_grade}
        The flog complexity for that debt is: #{max_module.complexity}
        Flay suspects #{max_module.duplication.to_i} areas of code duplication
        There are #{method_count} methods and #{smell_count} smell(s) from reek.
        The file is #{max_debt.linecount} lines long.
      RESULTS
    end

    def get_max_debt
      debts.max_by(&:to_i)
    end

    def report_text
      Todo.output(debts)
    end

    def get_total_debt
      debts.map(&:to_i).reduce(:+)
    end

    def method_count
      max_module.methods_count
    end

    def smell_count
      max_module.smells.count
    end

    def construct_paths(dir)
      if File.directory?(dir)
        Dir[ File.join(dir, '**', '*') ].reject { |path| File.directory?(path) || !(/\.rb$/ =~ path) }
      else
        Array(dir)
      end
    end
  end
end
