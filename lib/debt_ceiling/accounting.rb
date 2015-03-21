require 'rubycritic'
require 'rubycritic/cli/application'
require 'ostruct'
module DebtCeiling
  class Accounting
    DebtCeilingExceeded  = Class.new(StandardError)
    TargetDeadlineMissed = Class.new(StandardError)
    class << self
      def calculate(path)
        analysed_modules  = construct_rubycritic_modules(path)
        result            = OpenStruct.new
        result.debts      = construct_debts(analysed_modules)
        result.max_debt   = result.debts.max_by(&:to_i)
        result.total_debt = result.debts.map(&:to_i).reduce(:+)
        puts "Current total tech debt: #{result.total_debt}"
        puts "Largest source of debt is: #{result.max_debt.name} at #{result.max_debt.to_i}"
        result
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
        Rubycritic.create(mode: :ci, paths: Array(path)).critique
      end
    end
  end
end
