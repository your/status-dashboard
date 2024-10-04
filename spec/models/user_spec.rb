# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    describe "name" do
      it { is_expected.to validate_presence_of(:name) }
    end

    describe "email", aggregate_failures: true do
      it { is_expected.to validate_presence_of(:email) }
      it { is_expected.to allow_value("someone@changeme.com").for(:email) }
      it { is_expected.not_to allow_value("someone@anotheremail.com").for(:email) }

      describe "uniqueness" do
        context "when in presence of a deleted record" do
          let!(:user) { create(:user) }
          let(:new_user) { build(:user) }

          before do
            user.destroy!
          end

          it { expect(new_user.save!).to eq(true) }
        end
      end
    end

    describe "deletion", aggregate_failures: true do
      subject(:user) { build(:user) }

      context "when the record is marked for deletion" do
        before do
          user.marked_for_deletion = true
        end

        it do
          is_expected.to validate_inclusion_of(:delete_confirmation)
            .in_array([ "1" ])
            .with_message("confirmation is required")
        end
      end
    end

    describe "password", aggregate_failures: true do
      subject { user }

      before do
        user.valid?
      end

      context "when password is not complex" do
        let(:user) { build(:user, :with_simple_password) }

        it { expect(user.errors[:password]).to include(/is too short/) }
      end

      context "when password is blank" do
        let(:user) { build(:user, :without_password) }

        context "and password is required" do
          it { expect(user.errors[:password]).to include(/can't be blank/) }
        end

        context "and password is not required" do
          before do
            user.skip_password_validation = true
            user.valid?
          end

          it { expect(user.errors[:password]).to be_empty }
        end
      end
    end
  end

  describe "devise" do
    describe "password_archivable" do
      it { expect(User.password_archiving_count).to eq(3) }
    end

    describe "session_limitable" do
      it { expect(subject.skip_session_limitable?).to eq(false) }
    end

    describe "database authenticatable", aggregate_failures: true do
      it { expect(subject).to respond_to(:password=) }
      it { expect(subject).to respond_to(:password_confirmation=) }
    end

    describe "confirmable", aggregate_failures: true do
      it { expect(subject).to respond_to(:confirm) }
      it { expect(subject).to respond_to(:confirmed?) }
      it { expect(subject).to respond_to(:send_confirmation_instructions) }
    end

    describe "recoverable", aggregate_failures: true do
      it { expect(subject).to respond_to(:reset_password) }
      it { expect(subject).to respond_to(:send_reset_password_instructions) }
      it { expect(subject).to respond_to(:reset_password_period_valid?) }
    end

    describe "rememberable", aggregate_failures: true do
      it { expect(subject).to respond_to(:remember_me!) }
      it { expect(subject).to respond_to(:forget_me!) }
      it { expect(subject).to respond_to(:remember_me?) }
    end

    describe "validatable", aggregate_failures: true do
      it { is_expected.to validate_presence_of(:email) }
      it { is_expected.to validate_presence_of(:password) }
      it { is_expected.to validate_presence_of(:password) }
      it { is_expected.to validate_confirmation_of(:password) }
      it { is_expected.to validate_length_of(:password).is_at_least(15) }
    end

    describe "trackable", aggregate_failures: true do
      it { expect(subject).to respond_to(:sign_in_count) }
      it { expect(subject).to respond_to(:current_sign_in_at) }
      it { expect(subject).to respond_to(:last_sign_in_at) }
      it { expect(subject).to respond_to(:current_sign_in_ip) }
      it { expect(subject).to respond_to(:last_sign_in_ip) }
    end

    describe "timeoutable", aggregate_failures: true do
      it { expect(subject).to respond_to(:timeout_in) }
      it { expect(subject).to respond_to(:timedout?) }
    end

    describe "lockable", aggregate_failures: true do
      it { expect(subject).to respond_to(:lock_access!) }
      it { expect(subject).to respond_to(:unlock_access!) }
      it { expect(subject).to respond_to(:reset_failed_attempts!) }
      it { expect(subject).to respond_to(:access_locked?) }
      it { expect(subject).to respond_to(:send_unlock_instructions) }
      it { expect(subject).to respond_to(:resend_unlock_instructions) }
      it { expect(subject).to respond_to(:active_for_authentication?) }
      it { expect(subject).to respond_to(:inactive_message) }
      it { expect(subject).to respond_to(:valid_for_authentication?) }
      it { expect(subject).to respond_to(:increment_failed_attempts) }
      it { expect(subject).to respond_to(:unauthenticated_message) }
    end
  end

  describe "#admin?" do
    context "when user is not admin" do
      subject(:user) { build(:user, :non_admin) }

      it { expect(user.admin?).to eq(false) }
    end

    context "when user is admin" do
      subject(:user) { build(:user, :admin) }

      it { expect(user.admin?).to eq(true) }
    end
  end
end
