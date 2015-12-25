require_relative "source_control_systems/base"
require 'digest/sha1'
require 'json'
module DebtCeiling
  class ArcheologicalDig
    ARCHEOLOGY_RECORD_VERSION_NUMBER = "v0" #increment for backward incompatible changes in record format
    attr_reader :source_control, :records, :redis, :path, :opts

    def self.dig_json_key(path)
      project_name = File.expand_path(path).split('/').last
      "DebtCeiling_#{project_name}_#{ARCHEOLOGY_RECORD_VERSION_NUMBER}"
    end

    def initialize(path='.', opts={})
      @redis = redis_if_available
      @path = path
      @opts = opts
      @source_control =  SourceControlSystem::Base.create
      DebtCeiling.load_configuration unless opts[:preconfigured]
      @records = source_control.revisions_refs(path).map do |commit|
        if note = config_note_present_on_commit(commit)
          extract_record_from_note(note)
        else
          build_record(commit)
        end
      end
      redis.set(self.class.dig_json_key(path), records.to_json) if redis
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
        create_note_on_commit(result, commit) if DebtCeiling.memoize_records_in_repo
      end
      archeology_record(result, commit)
    end

    def redis_if_available
      require 'redis'
      host = ENV['REDIS_HOST'] || 'localhost'
      port = ENV['REDIS_PORT'] ? ENV['REDIS_PORT'].to_i : 6379
      Redis.new(host: host, port: port)
      rescue LoadError
    end

    def read_note_on(commit)
      if redis
        redis.get(commit_identifier(commit))
      else
        source_control.read_note_on(commit)
      end
    end

    def config_note_present_on_commit(commit)
      note = read_note_on(commit)
      matched = !!note.match(commit_identifier(commit)) if note
      note if matched
    end

    def extract_record_from_note(note)
      note.split("\n").each_cons(2).each do |comment, json|
        return JSON.parse(json) if comment.match(config_string)
      end
    end

    def create_note_on_commit(result, commit)
      note = <<-DATA
            #{commit_identifier(commit)}
            #{archeology_record_json(result, commit)}
            DATA
      if redis
        redis.set(commit_identifier(commit), note)
      else
        source_control.add_note_to(commit, note)
      end
    end

    def commit_identifier(commit)
      "debt_ceiling_#{commit}_#{config_string}"
    end

    def archeology_record_json(result, commit)
      json = "#{archeology_record(result, commit).to_json}"
      json.gsub!('"','\"') unless redis
      json
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

    def config_string
      @config_string ||= config_hash_string + ARCHEOLOGY_RECORD_VERSION_NUMBER
    end

    def config_hash_string
      Digest::SHA1.hexdigest(DebtCeiling.config_array.to_json)
    end

  end
end
