module DebtCeiling
  module CommonMethods

    def configuration
      DebtCeiling.configuration
    end

    def +(other)
      self.to_i + other.to_i
    end

  end
end