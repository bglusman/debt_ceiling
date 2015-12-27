require_relative "source_control_systems/base"
require_relative "analysis_caches/analysis_cache"
require 'digest/sha1'
require 'json'
module DebtCeiling
  class ArcheologicalDig
    ARCHEOLOGY_RECORD_VERSION_NUMBER = "v0" #increment for backward incompatible changes in record format
    attr_reader :source_control, :records, :cache, :path, :opts

    def self.dig_json_key(path)
      project_name = File.expand_path(path).split('/').last
      "DebtCeiling_#{project_name}_#{ARCHEOLOGY_RECORD_VERSION_NUMBER}"
    end

    def initialize(path='.', opts={})
      @cache = AnalysisCache.new(opts[:analysis_cache])
      @path = path
      @opts = opts
      @source_control =  SourceControlSystem::Base.create
    end

    def process
      DebtCeiling.load_configuration unless opts[:preconfigured]
      @records = source_control.revisions_refs(path)
        .map {|commit| cache.get(commit) { build_record(commit) } }
      cache.set(self.class.dig_json_key(path), records.to_json) if opts[:store_results]
      self
    end

    private

    def build_record(commit)
      result = nil
      source_control.travel_to_commit(commit) do
        result = Audit.new(path,
                           opts.merge(skip_report: true,
                                     warn_only: true,
                                     preconfigured: true,
                                     silent: true
                                     )
                          )
        record = archeology_record(result, commit)
        cache.set(commit, record) if DebtCeiling.memoize_records_in_repo
      end
      archeology_record(result, commit)
    end

    def archeology_record(result, commit)
      case DebtCeiling.archeology_detail
      when :low
        default_record(result, commit)
      else
        {max_debt: result.accounting.max_debt}.merge(default_record(result, commit))
      end
    end

    def default_record(result, commit)
      {debt: result.total_debt, failed: !!result.failed_condition?, commit: commit}
    end

  end
end
