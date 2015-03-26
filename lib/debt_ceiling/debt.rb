module DebtCeiling
  class Debt
    extend Forwardable
    DoNotWhitelistAndBlacklistSimulateneously = Class.new(StandardError)

    def_delegators :file_attributes,
                   :path, :analysed_module, :module_name, :linecount, :source_code
    def_delegators :configuration,
                  :whitelist, :blacklist

    def_delegator :analysed_module, :rating
    def_delegator :debt_amount, :to_i

    def initialize(file_attributes)
      @file_attributes  = file_attributes
      if valid_debt?
        debt_components = configuration.debt_types.map {|type| type.new(file_attributes) }
        @debt_amount    = debt_components.reduce(&:+)
      end
    end

    def name
      analysed_module.name || path.to_s.split('/').last
    end

    def +(other)
      to_i + other.to_i
    end

    def letter_grade
      rating.to_s.downcase.to_sym
    end

    private

    attr_reader :file_attributes, :debt_amount

    def configuration
      DebtCeiling.configuration
    end

    def internal_measure_debt
      debt_types.reduce(&:+)
    end

    def whitelist_includes?(debt)
      whitelist.find { |filename| debt.path.match filename }
    end

    def blacklist_includes?(debt)
      blacklist.find { |filename| debt.path.match filename }
    end

    def valid_debt?
      black_empty = blacklist.empty?
      white_empty = whitelist.empty?
      fail DoNotWhitelistAndBlacklistSimulateneously unless black_empty || white_empty
      (black_empty && white_empty) ||
      (black_empty && whitelist_includes?(self)) ||
      (white_empty && !blacklist_includes?(self))
    end
  end
end
