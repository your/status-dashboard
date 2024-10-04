# frozen_string_literal: true

require "rails_helper"

RSpec.describe Service, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_length_of(:name).is_at_most(25) }
    it { is_expected.to validate_inclusion_of(:status).in_array(described_class::ALL_STATUSES) }
  end

  describe "after_create_commit -> broadcast_message" do
    subject { build(:service, scope:) }

    before do
      allow(subject).to receive(:broadcast_replace_to)
      subject.save!
    end

    let(:expected_args) { { partial:, target:, locals: { services: Service.where(scope:).visible.order(name: :asc) } } }
    let(:partial) { "dashboard/services" }
    let(:target) { "services" }
    let(:stream) { "services-#{scope}" }

    %w[external internal].each do |scope|
      context "#{scope} scope" do
        let(:scope) { scope }

        it "broadcasts the message to the 'services-#{scope}' stream" do
          is_expected.to have_received(:broadcast_replace_to).with(stream, expected_args).once
        end
      end
    end
  end
end
