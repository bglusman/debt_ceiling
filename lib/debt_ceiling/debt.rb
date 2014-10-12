module DebtCeiling
  class Debt
    attr_reader :file_attributes
    attr_accessor :debt_amount
    def initialize(file_attributes)
      @file_attributes = file_attributes
      default_measure_debt
    end

    def default_measure_debt
      if self.respond_to?(:measure_file)
        cost = self.public_send(:measure_debt)
      end
      if !cost
        cost = if self.respond_to?(:augment_custom_debt)
          self.public_send(:augment_custom_debt) || 0
        else
          0
        end
        letter_grade = file_attributes.analyzed_module.rating.to_s.downcase
        cost_per_line = DebtCeiling.public_send("#{letter_grade}_current_cost_per_line")
        cost += file_attributes.linecount * cost_per_line
      end
      self.debt_amount = cost
    end

    def to_i
      debt_amount
    end

    def +(other)
      self.to_i + other.to_i
    end

  end
end