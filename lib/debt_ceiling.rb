require 'configurations'
require 'chronic'
require_relative 'debt_ceiling/accounting'
require_relative 'debt_ceiling/debt'

module DebtCeiling
  include Configurations
  extend Forwardable
  extend self

  attr_reader :total_debt
  def_delegator :configuration, :extension_path
  def_delegator :configuration, :blacklist
  def_delegator :configuration, :whitelist
  def_delegator :configuration, :cost_per_todo
  def_delegator :configuration, :deprecated_reference_pairs
  def_delegator :configuration, :manual_callouts
  def_delegator :configuration, :grade_points
  def_delegator :configuration, :reduction_date
  def_delegator :configuration, :reduction_target
  def_delegator :configuration, :debt_ceiling

  configuration_defaults do |c|
    c.extension_path = "#{Dir.pwd}/debt.rb"
    c.blacklist = []
    c.whitelist = []
    c.deprecated_reference_pairs = {}
    c.manual_callouts = ['TECH DEBT']
    c.grade_points = { a: 0, b: 10, c: 20, d: 40, f: 100 }
  end

  def load_configuration
    if File.exist?(Dir.pwd + '/.debt_ceiling.rb')
      load(Dir.pwd + '/.debt_ceiling.rb')
    elsif File.exist?(Dir.home + '/.debt_ceiling.rb')
      load(Dir.home + '/.debt_ceiling.rb')
    else
      puts "No .debt_ceiling.rb configuration file detected in #{Dir.pwd} or ~/, using defaults"
    end

    load extension_path if extension_path && File.exist?(extension_path)
    @loaded = true
  end

  def calculate(dir = '.', opts={preconfigured: false})
    load_configuration unless @loaded || opts[:preconfigured]
    @total_debt = DebtCeiling::Accounting.calculate(dir).total_debt
    evaluate
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


  def evaluate
    if debt_ceiling && debt_ceiling <= total_debt
      fail_test
    elsif reduction_target && reduction_target <= total_debt &&
          Time.now > Chronic.parse(reduction_date)
      fail_test
    end
    total_debt
  end

  def fail_test
    Kernel.exit 1
  end
end
