module DebtCeiling
  module SourceControlSystem

    class Git < Base
      register_system

      def self.supported?
        `git branch 2>&1` && $?.success?
      end

      def self.to_s
        "Git"
      end

      def revisions_count(path)
        revisions_refs(path).count
      end

      def revisions_refs(path)
        `git log --follow --format=%h #{path.shellescape}`.split("\n")
      end

      def date_of_last_commit(path)
        `git log -1 --date=iso --format=%ad #{path.shellescape}`.chomp!
      end

      def revision?
        head_reference && $?.success?
      end

      def head_reference
        `git rev-parse --verify HEAD`.chomp!
      end

      def add_note_to(ref, message)
        `git notes append #{ref} -m "#{message}"`
      end

      def read_note_on(ref)
        note = `git notes show #{ref}`
        note unless note.empty?
      end

      def travel_to_commit(ref)
        stash_successful = stash_changes
        `git checkout #{ref}`
        yield
      ensure
        `git checkout #{head_reference}`
        travel_to_original_state if stash_successful
      end

      def travel_to_head
        stash_successful = stash_changes
        yield
      ensure
        travel_to_original_state if stash_successful
      end

      private

      def stash_changes
        stashes_count_before = stashes_count
        `git stash`
        stashes_count_after = stashes_count
        stashes_count_after > stashes_count_before
      end

      def stashes_count
        `git stash list --format=%h`.count("\n")
      end

      def travel_to_original_state
        `git stash pop`
      end
    end

  end
end
