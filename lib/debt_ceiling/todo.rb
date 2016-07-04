module DebtCeiling
  class Todo

    def self.debts(debts)
      debts.map(&:custom_debt).compact.map(&:todo_report).compact.reduce(&:merge)
    end

    def self.output(debts)
      hash_debts = self.debts(debts)
      puts JSON.pretty_generate(hash_debts) if hash_debts
    end

    attr_reader :accounting, :dir, :loaded
    def initialize(dir = '.', opts = {})
      @accounting = opts[:accounting] || Accounting.new(dir)
    end

    def find_todos
      self.class.output(accounting.debts)
    end
  end
end
