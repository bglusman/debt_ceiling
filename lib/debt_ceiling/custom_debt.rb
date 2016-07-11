module DebtCeiling
  class CustomDebt
    extend Forwardable
    include CommonMethods
    DEFAULT_TODO_TEXT = 'TODO'
    def_delegators :configuration,
                   :deprecated_reference_pairs, :manual_callouts, :cost_per_todo

    def_delegators :file_attributes, :source_code, :path
    def_delegator  :debt_amount, :to_i

    def initialize(file_attributes)
      @report_text      = {}
      @matching_strings = []
      @file_attributes  = file_attributes
      @debt_amount      = default_measure_debt
    end

    def todo_report
      prepare_report
      { path => report_text } if report_text.any?
    end

    private

    attr_reader :file_attributes, :debt_amount, :report_text, :matching_strings

    def external_measure_debt
      public_send(:measure_debt) if self.respond_to?(:measure_debt)
    end

    def default_measure_debt
      external_measure_debt || debt_from_source_code_rules
    end

    def external_augmented_debt
      (public_send(:augment_debt) if respond_to?(:augment_debt)).to_i
    end

    def prepare_report
      source_code.each_line.each_with_index do |line, index|
        add_line(line, index + 1) if matching_strings.any? {|report_string| line.match(Regexp.escape(report_string))}
      end
    end

    def add_line(line, index)
      if DebtCeiling.todo_author_date_info
        author, date = find_author_date(index)
        report_text[index] = [line, author, date]
      else
        report_text[index] = line
      end
    end

    def find_author_date(line)
      blame = `git blame #{path} -L #{line}`.split("\n").first
      /.* \((?<author>[^\d]+) (?<date>.+)\)/ =~ blame
      [author, DateTime.parse(date)]
    rescue StandardError
      # TODO : also support mercurial ideally
      ["author:requiresGit", "date:requiresGit"]
    end

    def report_matches(string)
      matching_strings << string
    end

    def debt_from_source_code_rules
      manual_callout_debt +
      text_match_debt(DEFAULT_TODO_TEXT, cost_per_todo) +
      deprecated_reference_debt
    end

    def text_match_debt(string, cost)
      matches = source_code.split("\n").select {|code_line| code_line.scan(string) }
      report_matches(string) if matches.any?
      source_code.scan(string).count * cost.to_i # should be able to do matches.count * cost maybe? fails spec though
    end

    def manual_callout_debt
      manual_callouts.reduce(0) do |sum, callout|
        sum + debt_from_callout(callout)
      end
    end

    def deprecated_reference_debt
      deprecated_reference_pairs
        .reduce(0) {|accum, (string, value)| accum + text_match_debt(string, value.to_i) }
    end

    def debt_from_callout(callout)
      source_code.each_line.reduce(0) do |sum, line|
        match_data = line.match(Regexp.new(callout + '.*'))
        string = match_data.to_s.split(callout).last
        if string
          report_matches(string)
          amount = string.match(/\d+/).to_s
        end
        sum + amount.to_i
      end
    end
  end
end