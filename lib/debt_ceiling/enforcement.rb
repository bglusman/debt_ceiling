require 'rubycritic'
require 'ostruct'
module DebtCeiling
  class Enforcement
    class << self
      attr_reader :rules
      def add(rule)
        @rules ||= []
        @rules << rule
      end

      def process_directory(path, output=:destructured)
        modules = Rubycritic::Orchestrator.new.critique([path])
        debts = modules.map do |mod| 
          file_attributes = OpenStruct.new
          file_attributes.linecount = `wc -l #{mod.path}`.match(/\d+/)[0].to_i
          file_attributes.path = mod.path
          file_attributes.analyzed_module = mod
          debt_rule = Debt.new(file_attributes)
        end
        puts "Current total tech debt: #{debts.map(&:to_i).reduce(&:+)}"
      end
    end
  end
end
