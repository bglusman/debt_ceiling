require 'rubycritic'
require 'rubycritic/cli/application'
require 'ostruct'
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

      def construct_result
        analysed_modules   = construct_rubycritic_modules(path)
        result_from_analysed_modules(analysed_modules)
      end

      def result_from_analysed_modules(analysed_modules)
        _result            = OpenStruct.new
        _result.debts      = construct_debts(analysed_modules)
        _result.max_debt   = _result.debts.max_by(&:to_i)
        _result.total_debt = _result.debts.map(&:to_i).reduce(:+)
        _result
      end

      def print_results
        puts <<-RESULTS
          Current total tech debt: #{result.total_debt}
          Largest source of debt is: #{result.max_debt.name} at #{result.max_debt.to_i}
          The rubycritic grade for that debt is: #{result.max_debt.letter_grade}
          The flog complexity for that debt is: #{result.max_debt.analysed_module.complexity}
          Flay suspects #{result.max_debt.analysed_module.duplication.to_i} areas of code duplication
          There are #{method_count} methods and #{smell_count} smell(s) from reek
        RESULTS
      end

      def method_count
        result.max_debt.analysed_module.methods_count
      end

      def smell_count
        result.max_debt.analysed_module.smells.count
      end

      def construct_debts(modules)
        modules.map do |mod|
          path            = mod.path
          file_attributes = OpenStruct.new
          file_attributes.linecount = `wc -l #{path}`.match(/\d+/)[0].to_i
          file_attributes.path = path
          file_attributes.analysed_module = mod
          file_attributes.source_code = File.read(path)
          Debt.new(file_attributes)
        end
      end

      def construct_rubycritic_modules(path)
        Rubycritic.create(mode: :ci, format: :json, paths: Array(path)).critique
      end
    end
  end
end
