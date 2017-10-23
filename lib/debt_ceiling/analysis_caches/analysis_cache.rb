require_relative "git_note_adapter"
module DebtCeiling
  class AnalysisCache
    attr_reader :adapter, :project_name
    ANALYSIS_CACHE_HASH_LENGTH = 6
    def initialize(project_name, adapter=nil)
      @adapter = adapter
      @project_name = project_name
      @adapter ||= auto_select_adapter
    end

    def get(commit)
      text = adapter.get(commit_identifier(commit))
      if text
        extract_record_from_text(text)
      else
        yield if block_given?
      end
    end

    def set(commit, result)
      create_text_on_commit(commit, result)
    end

    private

    def create_text_on_commit(commit, result)
      text = <<-DATA
            #{commit_identifier(commit)}
            #{result.to_json}
            DATA
      adapter.set(commit_identifier(commit), text)
    end

    def extract_record_from_text(text)
      text.split("\n").each_cons(2).each do |comment, json|
        return JSON.parse(json) if comment.match(config_string)
      end
    end

    def auto_select_adapter
      redis_if_available || GitNoteAdapter.new
    end

    def redis_if_available
      require 'redis'
      host = ENV['REDIS_HOST'] || 'localhost'
      port = ENV['REDIS_PORT'] ? ENV['REDIS_PORT'].to_i : 6379
      Redis.new(host: host, port: port)
      rescue LoadError
    end

    def commit_identifier(commit)
      "DebtCeiling_#{project_name}_#{commit}_#{config_string}"
    end

    def config_string
      @config_string ||= "#{config_hash_string}_#{ArcheologicalDig::ARCHEOLOGY_RECORD_VERSION_NUMBER}"
    end

    def config_hash_string
      Digest::SHA1.hexdigest(DebtCeiling.config_array.to_json).slice(0...ANALYSIS_CACHE_HASH_LENGTH)
    end
  end
end