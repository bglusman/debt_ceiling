require_relative "source_control_systems/base"
require 'digest/sha1'
require 'json'
module DebtCeiling
  class ArcheologicalDig
    attr_reader :source_control, :records
    def initialize(path='.', opts={})
      @source_control =  SourceControlSystem::Base.create
      DebtCeiling.load_configuration unless opts[:preconfigured]
      @records = source_control.revisions_refs(path).map do |commit|
        if note = config_note_present_on_commit(commit)
          extract_record_from_note(note)
        else
          result = nil
          source_control.travel_to_commit(commit) do
            result = Audit.new(path, opts.merge(skip_report: true, warn_only: true, preconfigured: true))
            create_note_on_commit(result, commit)
          end
          archeology_record(result, commit)
        end
      end
    end

    def config_note_present_on_commit(commit)
      note = source_control.read_note_on(commit)
      note.match(config_string) if note
      note
    end

    def extract_record_from_note(note)
      puts 'extracting'
      'TODO'
    end

    def create_note_on_commit(result, commit)
      source_control.add_note_to(commit, <<-DATA
        debt_ceiling calculation id:#{config_string}
        #{archeology_record(result, commit).to_json}"
        DATA
      )
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
      Digest::SHA1.hexdigest(DebtCeiling.config_array.to_json)
    end

  end
end
