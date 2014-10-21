require 'rubycritic'
require 'ostruct'
module DebtCeiling
  class Accounting
    DebtCeilingExceeded  = Class.new(StandardError)
    TargetDeadlineMissed = Class.new(StandardError)
    class << self
      def calculate(path)
        analysed_modules = construct_rubycritic_modules(path)
        debts            = construct_debts(analysed_modules)
        max_debt         = debts.max_by(&:to_i)
        total_debt       = debts.map(&:to_i).reduce(:+)
        puts "Current total tech debt: #{total_debt}"
        puts "Largest source of debt is: #{max_debt.name} at #{max_debt.to_i}"
        total_debt
      end

      def construct_debts(modules)
        modules.map do |mod|
          file_attributes = OpenStruct.new
          file_attributes.linecount = `wc -l #{mod.path}`.match(/\d+/)[0].to_i
          file_attributes.path = mod.path
          file_attributes.analysed_module = mod
          file_attributes.source_code = File.read(mod.path)
          debt_rule = Debt.new(file_attributes)
        end
      end

      def construct_rubycritic_modules(path)
        if ENV['FULL_ANALYSIS']
          Rubycritic::Orchestrator.new.critique([path])
        else
        #temporarily use Rubycritic internals until they provide an API
          require "rubycritic/modules_initializer"
          require "rubycritic/analysers/complexity"
          require "rubycritic/analysers/smells/flay"

          modules = Rubycritic::ModulesInitializer.init([path])
          [Rubycritic::Analyser::Complexity, Rubycritic::Analyser::FlaySmells].each do |analyser|
            analyser.new(modules).run
          end
          modules
        end
      end
    end
  end
end
