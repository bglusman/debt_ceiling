require 'forwardable'
module DebtCeiling
  class Debt
    extend Forwardable
    DoNotWhitelistAndBlacklistSimulateneously = Class.new(StandardError)

    attr_accessor :debt_amount
    def_delegator :debt_amount, :to_i

    def initialize(file_attributes)
      @file_attributes  = file_attributes
      default_measure_debt if valid_debt?
    end

    def name
      file_attributes.analysed_module.name || path.to_s.split('/').last
    end

    def +(other)
      to_i + other.to_i
    end

    def letter_grade
      rating.to_s.downcase.to_sym
    end

    private

    attr_reader :file_attributes

    def default_measure_debt
      self.debt_amount = external_measure_debt || internal_measure_debt
    end

    def external_measure_debt
      public_send(:measure_debt) if self.respond_to?(:measure_debt)
    end

    def external_augmented_debt
      (public_send(:augment_debt) if respond_to?(:augment_debt)).to_i
    end

    def self.whitelist_includes?(debt)
      DebtCeiling.whitelist.find { |filename| debt.path.match filename }
    end

    def self.blacklist_includes?(debt)
      DebtCeiling.blacklist.find { |filename| debt.path.match filename }
    end

    def valid_debt?
      black_empty = DebtCeiling.blacklist.empty?
      white_empty = DebtCeiling.whitelist.empty?
      fail DoNotWhitelistAndBlacklistSimulateneously unless black_empty || white_empty
      (black_empty && white_empty) ||
      (black_empty && self.class.whitelist_includes?(self)) ||
      (white_empty && !self.class.blacklist_includes?(self))
    end

  end
end
