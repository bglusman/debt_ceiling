require 'configurations'
require 'chronic'
require_relative 'debt_ceiling/accounting'
require_relative 'debt_ceiling/debt'

module DebtCeiling
  include Configurations
  extend Forwardable
  extend self

  attr_reader :total_debt, :accounting_result

  def_delegators :configuration, :extension_path, :blacklist, :whitelist,
                 :cost_per_todo, :deprecated_reference_pairs, :manual_callouts,
                 :grade_points, :reduction_date, :reduction_target, :debt_ceiling,
                 :max_debt_per_module, :per_line_grade_multipliers

  configuration_defaults do |config|
    config.extension_path = "#{Dir.pwd}/debt.rb"
    config.blacklist = []
    config.whitelist = []
    config.deprecated_reference_pairs = {}
    config.manual_callouts = ['TECH DEBT']
    config.grade_points = { a: 0, b: 3, c: 13, d: 55, f: 144 }
    config.per_line_grade_multipliers = {a: 0, b: 0, c: 3, d: 21, f: 55}
  end


  def calculate(dir = '.', opts={preconfigured: false})
    load_configuration unless @loaded || opts[:preconfigured]
    @accounting_result = DebtCeiling::Accounting.calculate(dir)
    @total_debt = accounting_result.total_debt
    fail_test if failed_condition?
    total_debt
  end

  private

  def load_configuration
    pwd = Dir.pwd
    if File.exist?(pwd + '/.debt_ceiling.rb')
      load(pwd + '/.debt_ceiling.rb')
    elsif File.exist?(Dir.home + '/.debt_ceiling.rb')
      load(Dir.home + '/.debt_ceiling.rb')
    else
      puts "No .debt_ceiling.rb configuration file detected in #{pwd} or ~/, using defaults"
    end

    load extension_path if extension_path && File.exist?(extension_path)
    @loaded = true
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
    max_debt_per_module && max_debt_per_module <= accounting_result.max_debt.to_i
  end

  def fail_test
    Kernel.exit 1
  end
end
