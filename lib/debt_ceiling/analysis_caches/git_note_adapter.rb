module DebtCeiling
  class GitNoteAdapter
    NotAGitRepo = Class.new(StandardError)
    attr_reader :source_control

    def initialize
      raise NotAGitRepo unless SourceControlSystem::Git.supported?
      @source_control =  SourceControlSystem::Git.create
    end

    def get(key)
      config_note_present_on_commit(key, actual_commit(key))
    end

    def set(key, result)
      source_control.add_note_to(actual_commit(key), result.gsub!('"','\"'))
    end

    private

    def actual_commit(key)
      key.split('_')[2]
    end

    def read_note_on(commit)
      source_control.read_note_on(commit)
    end

    def config_note_present_on_commit(key, commit)
      note = read_note_on(commit)
      matched = !!note.match(key) if note
      note if matched
    end

  end
end