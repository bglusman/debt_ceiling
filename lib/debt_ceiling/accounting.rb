require 'rubycritic'
require 'ostruct'
module DebtCeiling
  class Accounting
    DebtCeilingExceeded  = Class.new(StandardError)
    TargetDeadlineMissed = Class.new(StandardError)
    class << self
      def calculate(path)
        modules = Rubycritic::Orchestrator.new.critique([path])
        debts      = construct_debts(modules)
        max_debt   = debts.max_by(&:to_i)
        total_debt = debts.map(&:to_i).reduce(&:+)
        puts "Current total tech debt: #{total_debt}"
        puts "Largest source of debt is: #{max_debt.file_attributes.analysed_module.name} at #{max_debt.to_i}"
        total_debt
      end

      def construct_debts(modules)
        modules.map do |mod| 
          file_attributes = OpenStruct.new
          file_attributes.linecount = `wc -l #{mod.path}`.match(/\d+/)[0].to_i
          file_attributes.path = mod.path
          file_attributes.analysed_module = mod
          debt_rule = Debt.new(file_attributes)
        end
      end
    end
  end
end
