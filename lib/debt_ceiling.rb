require 'configurations'
require 'chronic'
require 'rubycritic'
require 'rubycritic/cli/application'
require 'ostruct'
require 'forwardable'
require_relative 'debt_ceiling/accounting'
require_relative 'debt_ceiling/custom_debt'
require_relative 'debt_ceiling/static_analysis_debt'
require_relative 'debt_ceiling/debt'
require_relative 'debt_ceiling/compatibility'
require_relative 'debt_ceiling/file_attributes'

module DebtCeiling
  include Configurations
  extend Forwardable
  extend self

  attr_reader :total_debt, :accounting

  def_delegators :configuration,
                 :extension_path, :blacklist, :whitelist, :max_debt_per_module, :reduction_date,
                 :reduction_target, :debt_ceiling

  configuration_defaults do |config|
    config.extension_path = "#{Dir.pwd}/custom_debt.rb"
    config.blacklist = []
    config.whitelist = []
    config.deprecated_reference_pairs = {}
    config.manual_callouts = ['TECH DEBT']
    config.grade_points = { a: 0, b: 3, c: 13, d: 55, f: 144 }
    config.complexity_multiplier    = 0.5
    config.method_count_multiplier  = 0.5
    config.smells_multiplier        = 3
    config.duplication_multiplier   = 1.5
    config.ideal_max_line_count     = 100
    config.cost_per_line_over_ideal = 1
    config.debt_types               = [CustomDebt, StaticAnalysisDebt]
  end


  def calculate(dir = '.', opts={preconfigured: false})
    @total_debt = accounting(dir, opts).total_debt
    accounting.print_results unless opts[:skip_report]
    fail_test if failed_condition?
    total_debt
  end

  def accounting(dir = '.', opts={preconfigured: false})
    @accounting ||= begin
      load_configuration unless @loaded || opts[:preconfigured]
      Accounting.new(dir)
    end
  end

  def load_configuration(config_file_name=".debt_ceiling.rb")
    pwd = Dir.pwd
    home = Dir.home
    if File.exist?("#{pwd}/#{config_file_name}")
      load("#{pwd}/#{config_file_name}")
    elsif File.exist?("#{home}/#{config_file_name}")
      load("#{home}/#{config_file_name}")
    else
      puts "No #{config_file_name} configuration file detected in #{pwd} or ~/, using defaults"
    end

    load extension_path if extension_path && File.exist?(extension_path)
    @loaded = true
  end

  def clear
    @loaded     = nil
    @accounting = nil
  end

  private


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
