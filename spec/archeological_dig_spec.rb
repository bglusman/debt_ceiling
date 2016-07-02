require 'spec_helper'
require 'debt_ceiling'

COMMIT_SHA = '94f98c2'

describe DebtCeiling::ArcheologicalDig do

  CONFIG_STRING = "fake_config_string"
  COMMIT_SHA_MSG =  "debt_ceiling_#{COMMIT_SHA}_#{CONFIG_STRING}#{described_class::ARCHEOLOGY_RECORD_VERSION_NUMBER}\n            {\"debt\":100,\"failed\":false,\"commit\":\"#{COMMIT_SHA}\"}\n"

  let(:fake_source_control) { double(DebtCeiling::SourceControlSystem::Git) }
  let(:fake_audit) { double(DebtCeiling::Audit) }
  let(:total_debt) { 100 }
  let(:failed_condition) { false }
  before do
    allow(DebtCeiling::SourceControlSystem::Git).to receive(:new).and_return(fake_source_control)
    allow(fake_source_control).to receive(:revisions_refs).and_return([COMMIT_SHA])
    allow(fake_source_control).to receive(:travel_to_commit).with(COMMIT_SHA).and_yield
    allow(DebtCeiling::Audit).to receive(:new).and_return(fake_audit)
    allow(fake_audit).to receive(:total_debt).and_return(total_debt)
    allow(fake_audit).to receive(:failed_condition?).and_return(failed_condition)
  end


  context "without redis" do
    before do
      DebtCeiling.configure {|c| c.memoize_records_in_repo = true }
      allow(fake_source_control).to receive(:read_note_on).with(COMMIT_SHA).and_return COMMIT_SHA_MSG
      allow(fake_source_control).to receive(:add_note_to)
    end
    it 'adds debt for todos with specified value' do
      dig = DebtCeiling::ArcheologicalDig.new('').process
      expect(dig.records.map(&:stringify_keys)).to include(
        "debt" => total_debt, "failed" => failed_condition, "commit" => COMMIT_SHA
        )
    end
  end
end

class Hash
  def stringify_keys
    map {|k, v| [k.to_s, v] }.to_h
  end
end

