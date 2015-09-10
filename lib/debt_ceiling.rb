require 'configurations'
require 'chronic'
require 'sparkr'
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
require_relative 'debt_ceiling/archeological_dig'

module DebtCeiling
  include Configurations
  extend Forwardable
  extend self
  CONFIGURATION_OPTIONS = [
    :extension_path,
    :blacklist, :whitelist,
    :max_debt_per_module,
    :reduction_date,
    :reduction_target,
    :debt_ceiling,
    :deprecated_reference_pairs,
    :manual_callouts,
    :grade_points,
    :complexity_multiplier,
    :method_count_multiplier,
    :smells_multiplier,
    :duplication_multiplier,
    :ideal_max_line_count,
    :cost_per_line_over_ideal,
    :debt_types,
    :archeology_detail,
    :memoize_records_in_repo
  ]
  CONFIG_FILE_NAME = ".debt_ceiling.rb"
  CONFIG_LOCATIONS = ["#{Dir.pwd}/#{CONFIG_FILE_NAME}", "#{Dir.home}/#{CONFIG_FILE_NAME}"]
  NO_CONFIG_FOUND  = "No #{CONFIG_FILE_NAME} configuration file detected in #{Dir.pwd} or ~/, using defaults"

  def_delegators  :configuration, *CONFIGURATION_OPTIONS


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
    config.archeology_detail        = :low
    config.memoize_records_in_repo  = true #is this OK as a default? effects repo
  end


  def audit(dir='.', opts= {})
    Audit.new(dir, opts)
  end

  def dig(dir='.', opts={})
    dig = ArcheologicalDig.new(dir, opts)
    puts Sparkr.sparkline(dig.records.map {|r| r['debt'] })
    dig
  end

  def load_configuration
    config_file_location ? load(config_file_location) : puts(NO_CONFIG_FOUND)

    load extension_path if extension_path && File.exist?(extension_path)
    @loaded = true
  end

  def config_file_location
    CONFIG_LOCATIONS.find {|loc| File.exist?(loc) }
  end

  def config_array
    CONFIGURATION_OPTIONS.map {|option| public_send(option) }
  end

end
