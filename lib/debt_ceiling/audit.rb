module DebtCeiling
  class Audit
    extend Forwardable

    CONFIG_FILE_NAME = ".debt_ceiling.rb"
    CONFIG_LOCATIONS = ["#{Dir.pwd}/#{CONFIG_FILE_NAME}", "#{Dir.home}/#{CONFIG_FILE_NAME}"]
    NO_CONFIG_FOUND  = "No #{CONFIG_FILE_NAME} configuration file detected in #{Dir.pwd} or ~/, using defaults"

    attr_reader :accounting, :dir, :loaded

    def_delegators :configuration,
                   :extension_path, :debt_ceiling, :reduction_target, :reduction_date, :max_debt_per_module

    def_delegator :accounting, :total_debt

    def initialize(dir = '.', opts = {})
      @loaded     = opts[:preconfigured]
      @dir        = dir
      @accounting = perform_accounting
      accounting.print_results unless opts[:skip_report]
      fail_test if failed_condition?
    end

    private

    def load_configuration
      config_file_location ? load(config_file_location) : puts(NO_CONFIG_FOUND)

      load extension_path if extension_path && File.exist?(extension_path)
      @loaded = true
    end

    def config_file_location
      CONFIG_LOCATIONS.find {|loc| File.exist?(loc) }
    end

    def perform_accounting
      load_configuration unless loaded
      Accounting.new(dir)
    end

    def configuration
      DebtCeiling.configuration
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

    def failed_condition?
      exceeded_total_limit? || missed_target? || max_debt_per_module_exceeded?
    end

    def exceeded_total_limit?
      debt_ceiling && debt_ceiling <= total_debt
    end

    def missed_target?
      reduction_target && reduction_target <= total_debt &&
            Time.now > Chronic.parse(reduction_date)
    end

    def max_debt_per_module_exceeded?
      max_debt_per_module && max_debt_per_module <= accounting.max_debt.to_i
    end

    def fail_test
      at_exit do
        Kernel.exit 1
      end
    end
  end
end
