module DebtCeiling
  class Debt
    DoNotWhitelistAndBlacklistSimulateneously = Class.new(StandardError)

    attr_reader :file_attributes, :path, :analysed_module, :module_name, :linecount
    attr_accessor :debt_amount
    def initialize(file_attributes)
      @file_attributes  = file_attributes
      @path             = file_attributes.path
      @analysed_module  = file_attributes.analysed_module
      @module_name      = file_attributes.name
      @linecount        = file_attributes.linecount
      default_measure_debt if valid_debt?
    end

    def default_measure_debt
      if self.respond_to?(:measure_debt)
        cost = self.public_send(:measure_debt)
      end
      if !cost
        cost = if self.respond_to?(:augment_debt)
          self.public_send(:augment_debt) || 0
        else
          0
        end
        letter_grade = file_attributes.analysed_module.rating.to_s.downcase
        cost_per_line = DebtCeiling.public_send("#{letter_grade}_current_cost_per_line")
        cost += file_attributes.linecount * cost_per_line
      end
      self.debt_amount = cost
    end

    def valid_debt?
      black_empty = DebtCeiling.blacklist.empty?
      white_empty = DebtCeiling.whitelist.empty?
      raise DoNotWhitelistAndBlacklistSimulateneously if (!black_empty && !white_empty)
      (black_empty && white_empty) ||
      (black_empty && self.class.whitelist_includes?(self)) ||
      (white_empty && !self.class.blacklist_includes?(self))
    end

    def self.whitelist_includes?(debt)
      DebtCeiling.whitelist.detect {|filename| filename.match debt.path }
    end

    def self.blacklist_includes?(debt)
      DebtCeiling.blacklist.detect {|filename| filename.match debt.path }
    end

    def to_i
      debt_amount.to_i
    end

    def +(other)
      self.to_i + other.to_i
    end

  end
end