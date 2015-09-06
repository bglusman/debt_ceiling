module DebtCeiling
  module SourceControlSystem
    require 'open3'
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
        popen3("git log --follow --format=%h #{path.shellescape}").split("\n")
      end

      def date_of_last_commit(path)
        popen3("git log -1 --date=iso --format=%ad #{path.shellescape}").chomp!
      end

      def revision?
        head_reference && $?.success?
      end

      def head_reference
        popen3("git rev-parse --verify HEAD").chomp
      end

      def add_note_to(ref, message)
        popen3(%Q(git notes append #{ref} -m "#{message}"))
      end

      def read_note_on(ref)
        popen3("git notes show #{ref}")
      end

      def travel_to_commit(ref)
        stash_successful = stash_changes
        current_branch = popen3("git symbolic-ref HEAD").chomp.split('/').last
        popen3("git checkout #{ref}")
        yield
      ensure
        popen3("git checkout #{current_branch}")
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
        popen3("git stash")
        stashes_count_after = stashes_count
        stashes_count_after > stashes_count_before
      end

      def stashes_count
        popen3("git stash list --format=%h").count("\n")
      end

      def travel_to_original_state
        popen3("git stash pop")
      end

      def popen3(cmd)
        Open3.popen3(cmd) do |_,stdout,error|
          stdout.read if error.read.empty?
        end
      end
    end
  end
end
