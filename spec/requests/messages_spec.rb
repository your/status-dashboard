# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Messages", type: :request do
  describe "POST /admin/messages" do
    let(:scope) { "unknown" }

    before do
      sign_in(user) if authenticated
      get switch_dashboard_path if scope == "internal"
      post "/admin/messages", params: { message: { body: "Test message #{scope}" } }
    end

    context "when user is not authenticated" do
      let(:authenticated) { false }

      it { expect(response).to redirect_to(new_user_session_url) }
    end

    context "when user is authenticated" do
      shared_examples "saves the message accordingly" do
        let(:expected_message) { "Test message #{scope}" }
        let(:expected_attributes) do
          { scope:, body: expected_message, updated_by: user }
        end

        it { expect(response).to redirect_to(admin_url) }
        it "displays the expected message" do
          follow_redirect!
          expect(response.body).to include(expected_message)
        end
        it { expect(Message.last).to have_attributes(expected_attributes) }
      end

      let(:authenticated) { true }
      let(:user) { create(:user) }

      context "when scope is external", :aggregate_failures do
        let(:scope) { "external" }

        include_examples "saves the message accordingly"
      end

      context "when scope is internal", :aggregate_failures do
        let(:scope) { "internal" }

        include_examples "saves the message accordingly"
      end
    end
  end
end
