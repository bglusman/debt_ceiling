module DebtCeiling
  module SourceControlSystem
    class Double < Base
      def revisions_count(_)
        "N/A"
      end

      def date_of_last_commit(_)
        nil
      end

      def add_note_to(ref, message)
        nil
      end

      def read_note_on(ref)
        nil
      end

      def travel_to_commit(ref)
        nil
      end

      def revisions_count(path)
        nil
      end

      def revisions_refs(path)
        []
      end

      def revision?
        false
      end
    end

  end
end
