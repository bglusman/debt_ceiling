module DebtCeiling
  class Todo  # maybe?
    attr_reader :accounting, :dir, :loaded
    def initialize(dir = '.', opts = {})
      @loaded     = opts[:preconfigured]
      @dir        = dir
      DebtCeiling.load_configuration unless loaded
      # Ideally we'd modify config with
      # DebtCeiling.configure { |c| c.debt_types = [CustomDebt] }
      # or something here, but configurations gem may not support ad-hoc modifying?
      # above would overwrite entire config.  TODO: Investigate further
      @accounting = opts[:accounting] || Accounting.new(dir)
    end

    def find_todos
      puts accounting.report_text.flatten
    end
  end
end
