require_relative "source_control_systems/base"
require_relative "analysis_caches/analysis_cache"
require 'digest/sha1'
require 'json'
module DebtCeiling
  class ArcheologicalDig
    ARCHEOLOGY_RECORD_VERSION_NUMBER = "v1" #increment for backward incompatible changes in record format
    attr_reader :source_control, :records, :cache, :project_name, :path, :opts

    def initialize(path='.', opts={})
      @path = path
      @opts = opts
      @project_name = sanitized_project_name
      @cache = AnalysisCache.new(project_name, opts[:analysis_cache])
      @source_control =  SourceControlSystem::Base.create
    end

    def process
      DebtCeiling.load_configuration unless opts[:preconfigured]
      @records = source_control.revisions_refs(path).map {|commit| process_commit(commit) }
      cache.set(dig_json_key(path), records.to_json) if opts[:store_results]
      self
    end

    private

    def sanitized_project_name
      name = opts[:project_name] || File.expand_path(path).split('/').last
      name.gsub('_', '-')
    end

    def dig_json_key(path)
      "DebtCeiling_#{project_name}_#{ARCHEOLOGY_RECORD_VERSION_NUMBER}"
    end

    def process_commit(commit)
      cache.get(commit) { audit_commit(commit) }
    end

    def audit_commit(commit)
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
        record
      end
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
      {'debt' => result.total_debt, 'failed' => !!result.failed_condition?, 'commit' => commit}
    end

  end
end
