require_relative 'debt_ceiling/accounting'
require_relative 'debt_ceiling/debt'
require 'chronic'

module DebtCeiling
  extend self

  def calculate(dir=".")
    if File.exists?(Dir.pwd + '/.debt_ceiling')
       File.open(Dir.pwd + "/.debt_ceiling") {|f| DebtCeiling.module_eval(f.read)}
    elsif File.exists?(Dir.home + '/.debt_ceiling')
       File.open(Dir.home + '/.debt_ceiling') {|f| DebtCeiling.module_eval(f.read)}
    else
      puts "No .debt_ceiling configuration file detected in #{Dir.pwd} or ~/, using defaults"
    end

    extension_path = DebtCeiling.current_extension_file_path
    load extension_path if extension_path && File.exists?(extension_path)

    @debt = DebtCeiling::Accounting.calculate(dir)
    evaluate
  end

  @extension_file_path = "#{Dir.pwd}/debt.rb"
  def extension_file_path(path)
    @extension_file_path = path
  end

  def current_extension_file_path
    @extension_file_path
  end

  def blacklist_matching(matchers)
    @blacklist = matchers.map {|matcher| Regexp.new(matcher)}
  end

  def whitelist_matching(matchers)
    @whitelist =  matchers.map {|matcher| Regexp.new(matcher)}
  end

  def set_debt_ceiling(value)
    @ceiling_amount = value
  end

  def debt_reduction_target_and_date(target_value, date_to_parse)
    @reduction_target = target_value
    @reduction_date   = Chronic.parse(date_to_parse)
  end

  def evaluate
    if ceiling_amount && ceiling_amount <= debt
      fail_test
    elsif reduction_target && reduction_target <= debt && 
          Time.now > reduction_date
      fail_test
    end
  end

  def fail_test
    Kernel.exit 1
  end

  attr_reader :blacklist, :whitelist, :ceiling_amount, :reduction_date, :reduction_target, :debt
  @blacklist = []
  @whitelist = []

  GRADE_MAP = {a: 0, b: 10, c: 20, d: 40, f: 100} #arbitrary default grades for now
  GRADE_MAP.keys.each do |grade|
    instance_variable_set "@#{grade}_cost_per_line", GRADE_MAP[grade]
    define_method("#{grade}_current_cost_per_line") do
      instance_variable_get "@#{grade}_cost_per_line"
    end
    define_method("#{grade}_cost_per_line") do |value| #def set methods, no =
      instance_variable_set "@#{grade}_cost_per_line", value
    end
  end
end
