# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  describe "GET /(:scope)" do
    context "without scope param", :aggregate_failures do
      let(:scope) { "" }

      before do
        create(:message, body: "Test message external", scope: "external")
        get "/#{scope}"
      end

      it { expect(response).to have_http_status(:ok) }

      it { expect(response.body).to include("Test message external") }
      it { expect(response.body).not_to include("Test message internal") }
    end

    context "with scope param" do
      context "when scope is external" do
        let(:scope) { "external" }

        before do
          create(:message, body: "Test message #{scope}", scope:)
          get "/#{scope}"
        end

        it { expect(response).to redirect_to(dashboard_path) }
      end

      context "when scope is internal", :aggregate_failures do
        let(:scope) { "internal" }

        before do
          create(:message, body: "Test message #{scope}", scope:)
          get "/#{scope}"
        end

        it { expect(response).to have_http_status(:ok) }

        it { expect(response.body).not_to include("Test message external") }
        it { expect(response.body).to include("Test message internal") }
      end

      context "when scope is neither external nor internal" do
        let(:scope) { "incorrect" }

        before do
          get "/#{scope}"
        end

        it { expect(response).to have_http_status(:not_found) }
      end
    end
  end
end
