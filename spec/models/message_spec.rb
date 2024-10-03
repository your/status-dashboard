# frozen_string_literal: true

require "rails_helper"

RSpec.describe Message, type: :model do
  describe "validations" do
    describe "must_prevent_update?" do
      context "when the record is new" do
        let(:message) { build(:message) }

        before { message.save }

        it { expect(message).to be_persisted }
      end

      context "when the record is not new" do
        let!(:message) { create(:message) }

        before { message.update(body: "Another message") }

        it { expect(message.errors[:base]).to include("cannot be updated, create a new record if necessary") }
        it { expect(message.reload.body).not_to eq("Another message") }
      end
    end

    describe "must_prevent_destroy?" do
      context "when the record has been persisted" do
        let!(:message) { create(:message) }

        before { message.destroy }

        it { expect(message.errors[:base]).to include("cannot be deleted, create a new record if necessary") }
        it { expect(message.reload).to eq(message) }
      end
    end
  end

  describe "after_create_commit -> broadcast_message" do
    subject { build(:message, scope:) }

    before do
      allow(subject).to receive(:broadcast_replace_to)
      subject.save!
    end

    let(:expected_args) { { partial:, target:, locals: { message: subject } } }
    let(:partial) { "dashboard/message" }
    let(:target) { "message" }
    let(:stream) { "message-#{scope}" }

    %w[external internal].each do |scope|
      context "#{scope} scope" do
        let(:scope) { scope }

        it "broadcasts the message to the 'message-#{scope}' stream" do
          is_expected.to have_received(:broadcast_replace_to).with(stream, expected_args).once
        end
      end
    end
  end
end
