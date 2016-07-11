module DebtCeiling
  class Audit
    extend Forwardable
    include CommonMethods
    undef :+

    FAILURE_MESSAGE       = "DEBT CEILING FAILURE: "
    TOTAL_LIMIT           = "EXCEEDED TOTAL DEBT CEILING "
    PER_MODULE_MESSAGE    = "MAX DEBT PER MODULE EXCEEDED IN AT LEAST ONE LOCATION"
    MISSED_TARGET_MESSAGE = "MISSED DEBT REDUCTION TARGET "

    attr_reader :accounting, :dir, :loaded

    def_delegators :configuration,
                   :debt_ceiling, :reduction_target, :reduction_date, :max_debt_per_module, :debt_types, :report_todos

    def_delegator :accounting, :total_debt

    def initialize(dir = '.', opts = {})
      @loaded     = opts[:preconfigured]
      @dir        = dir
      @accounting = perform_accounting
      @todos      = find_todos if report_todos && debt_types.include?(CustomDebt)
      accounting.print_results unless opts[:skip_report]
      puts failure_message unless opts[:silent]
      puts @todos if report_todos
      fail_test if failed_condition? && !opts[:warn_only]
    end

    def failed_condition?
      exceeded_total_limit || missed_target || max_debt_per_module_exceeded
    end

    private

    def find_todos
      Todo.new(@dir, accounting: accounting, preconfigured: true).find_todos
    end

    def perform_accounting
      DebtCeiling.load_configuration unless loaded
      Accounting.new(dir)
    end

    def blacklist_matching(matchers)
      @blacklist = matchers.map { |matcher| Regexp.new(matcher) }
    end

    def whitelist_matching(matchers)
      @whitelist =  matchers.map { |matcher| Regexp.new(matcher) }
    end


    def debt_per_reference_to(string, value)
      deprecated_reference_pairs[string] = value
    end

    def failure_message
      <<-MESG
        #{FAILURE_MESSAGE if failed_condition?}#{exceeded_total_limit}#{missed_target}
        #{max_debt_per_module_exceeded}
      MESG
    end

    def exceeded_total_limit
      TOTAL_LIMIT if debt_ceiling && debt_ceiling <= total_debt
    end

    def missed_target
      MISSED_TARGET_MESSAGE if reduction_target && reduction_target <= total_debt &&
            Time.now > Chronic.parse(reduction_date)
    end

    def max_debt_per_module_exceeded
      PER_MODULE_MESSAGE if max_debt_per_module && max_debt_per_module <= accounting.max_debt.to_i
    end

    def fail_test
      at_exit do
        Kernel.exit 1
      end
    end
  end
end
