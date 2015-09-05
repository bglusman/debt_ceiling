require "shellwords"
#copied from rubycritic, hope/plan to augment, pull into seperate gem and PR as shared code?
module DebtCeiling
  module SourceControlSystem

    class Base
      @@systems = []

      def self.register_system
        @@systems << self
      end

      def self.systems
        @@systems
      end

      def self.create
        supported_system = systems.find(&:supported?)
        if supported_system
          supported_system.new
        else
          puts "DebtCeiling can provide more feedback if you use a #{connected_system_names} repository."
          Double.new
        end
      end

      def self.connected_system_names
        "#{systems[0...-1].join(', ')} or #{systems[-1]}"
      end
    end

  end
end

require_relative "base"
require_relative "git"
require_relative "mercurial"
