# frozen_string_literal: true

require "rails_helper"

RSpec.describe Devise::Mailer do
  subject(:mailer) { described_class.new }

  let(:user) { build(:user) }
  let(:token) { "dummy" }
  let(:url) { ENV.fetch("DOMAIN_URL", "http://localhost") }

  let(:expected_personalisation) do
    {
      confirmation_instructions: {
        confirmation_url: "#{url}/admin/confirmation?confirmation_token=#{token}",
        token_expiry_period: "7 days",
        user_name: user.name
      },
      reset_password_instructions: {
        edit_password_url: "#{url}/admin/password-reset/edit?reset_password_token=#{token}",
        token_expiry_period: "about 6 hours",
        user_email: user.email,
        user_name: user.name
      },
      password_change: {
        user_name: user.name
      },
      unlock_instructions: {
        user_name: user.name,
        unlock_url: "#{url}/admin/unlock?unlock_token=#{token}",
        reset_password_url: "/admin/password-reset/new"
      }
    }
  end

  describe ".confirmation_instructions" do
    it "e-mails the user using the correct template and personalisation" do
      allow(mailer).to receive(:set_template).with(described_class::GOVUK_NOTIFY_TEMPLATES[:confirmation_instructions])
      allow(mailer).to receive(:set_personalisation).with(expected_personalisation[:confirmation_instructions])
      allow(mailer).to receive(:mail).with(to: user.email)

      mailer.confirmation_instructions(user, token)
    end
  end

  describe ".reset_password_instructions" do
    it "e-mails the user using the correct template and personalisation" do
      allow(mailer).to receive(:set_template).with(described_class::GOVUK_NOTIFY_TEMPLATES[:reset_password_instructions])
      allow(mailer).to receive(:set_personalisation).with(expected_personalisation[:reset_password_instructions])
      allow(mailer).to receive(:mail).with(to: user.email)

      mailer.reset_password_instructions(user, token)
    end
  end

  describe ".password_change" do
    it "e-mails the user using the correct template and personalisation" do
      allow(mailer).to receive(:set_template).with(described_class::GOVUK_NOTIFY_TEMPLATES[:password_change])
      allow(mailer).to receive(:set_personalisation).with(expected_personalisation[:password_change])
      allow(mailer).to receive(:mail).with(to: user.email)

      mailer.password_change(user, token)
    end
  end

  describe ".unlock_instructions" do
    it "e-mails the user using the correct template and personalisation" do
      allow(mailer).to receive(:set_template).with(described_class::GOVUK_NOTIFY_TEMPLATES[:unlock_instructions])
      allow(mailer).to receive(:set_personalisation).with(expected_personalisation[:unlock_instructions])
      allow(mailer).to receive(:mail).with(to: user.email)

      mailer.unlock_instructions(user, token)
    end
  end
end
