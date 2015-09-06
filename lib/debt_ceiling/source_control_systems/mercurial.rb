module DebtCeiling
  module SourceControlSystem

    class Mercurial < Base
      register_system

      def self.supported?
        `hg verify 2>&1` && $?.success?
      end

      def self.to_s
        "Mercurial"
      end

      def revisions_count(path)
        `hg log #{path.shellescape} --template '1'`.size
      end

      def date_of_last_commit(path)
        `hg log #{path.shellescape} --template '{date|isodate}' --limit 1`.chomp
      end

      def add_note_to(ref, message)
        nil #unsupported AFAIK
      end

      def read_note_on(ref)
        nil
      end

      def travel_to_commit(ref)
        nil #TODO
      end

      def revisions_count(path)
        nil #TODO
      end

      def revisions_refs(path)
        [] #TODO
      end

      def revision?
        false
      end
    end

  end
end
