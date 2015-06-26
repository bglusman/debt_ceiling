require 'configurations'
require 'chronic'
require 'rubycritic'
require 'rubycritic/cli/application'
require 'ostruct'
require 'forwardable'
require_relative 'debt_ceiling/common_methods'
require_relative 'debt_ceiling/audit'
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


  def audit(dir='.', opts= {})
    Audit.new(dir, opts)
  end
end
