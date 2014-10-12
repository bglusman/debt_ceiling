require 'ripper'
require_relative 'debt_ceiling/enforcement'
require_relative 'debt_ceiling/debt'



module DebtCeiling
  extend self

  def debt_ceiling(pattern, message=nil, options={})
    if pattern.kind_of?(String)
      rule = Rule.new(pattern, message, options)
      DebtCeiling::Enforcement.add(rule)
    else
      DebtCeiling::Enforcement.add(self.send(pattern))
    end
  end

  def enforce(dir=".")
    DebtCeiling::Enforcement.process_directory(dir, :stdout)
  end

  def validate_files(files)
    files.reduce(error: false, output:"") do |results, file|
      error, output = DebtCeiling::Enforcement.process_file(file)
      results[:error] ||= error
      results[:output] += output
      results
    end
  end

  @extension_file_path = "#{Dir.pwd}/debt_rule.rb"
  def extension_file_path(path)
    @extension_file_path = path
  end

  def current_extension_file_path
    @extension_file_path
  end

  GRADES = [:a, :b, :c, :d, :f]
  GRADE_DEFAULTS = [0, 10, 20, 40, 100]
  GRADE_MAP = GRADES.zip(0..4).to_h
  GRADES.each do |grade|
    default_index = GRADE_MAP[grade]
    instance_variable_set "@#{grade}_cost_per_line", GRADE_DEFAULTS[default_index]
    define_method("#{grade}_current_cost_per_line") do
      instance_variable_get "@#{grade}_cost_per_line"
    end
    define_method("#{grade}_cost_per_line") do |value| #def set methods, no =
      instance_variable_set "@#{grade}_cost_per_line", value
    end
  end
end
