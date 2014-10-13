require_relative 'debt_ceiling/accounting'
require_relative 'debt_ceiling/debt'



module DebtCeiling
  extend self

  def calculate(dir=".")
    DebtCeiling::Accounting.process_directory(dir)
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
  attr_reader :blacklist, :whitelist
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
