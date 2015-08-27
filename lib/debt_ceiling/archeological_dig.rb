module DebtCeiling
  class ArcheologicalDig

    def initialize(path='.', opts={})
      selected_git_commits(path) do |commit|
        checkout_commit(commit)
        next if config_note_present_on_commit(commit)
        result = Audit.new(opts.merge(skip_report: true, warn_only: true, preconfigured: true))
        create_note_on_commit(result, commit)
      end
    end

    def selected_git_commits(path)
      [].each do |x|
        yield x
      end
    end

    def checkout_commit(commit)
    end

    def config_note_present_on_commit(commit)
    end

    def create_note_on_commit(result, commit)
    end

  end
end
