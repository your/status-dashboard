# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Services", type: :request do
  let(:user) { create(:user) }

  describe "GET /admin/services/new" do
    before do
      sign_in(user) if authenticated
      get "/admin/services/new"
    end

    context "when user is not authenticated" do
      let(:authenticated) { false }

      it { expect(response).to redirect_to(new_user_session_url) }
    end

    context "when user is authenticated" do
      let(:authenticated) { true }

      it { expect(response).to have_http_status(:success) }
      it { expect(response.body).to include("Changes to this page will be published") }
    end
  end

  describe "POST /admin/services" do
    let(:message_update_confirmation) { 0 }
    let(:scope) { "external" }
    let(:service_params) do
      {
        name: "Test service",
        status: "Good Service",
        hidden: false,
        message_update_confirmation:,
        mirror_status_confirmation: nil
      }
    end

    before do
      sign_in(user) if authenticated
      get switch_dashboard_path if scope == "internal"
      post "/admin/services", params: { service: service_params }
    end

    context "when user is not authenticated" do
      let(:authenticated) { false }

      it { expect(response).to redirect_to(new_user_session_url) }
    end

    context "when user is authenticated" do
      let(:authenticated) { true }

      context "when user did not confirm they will update the message" do
        it { expect(response.body).to include("confirmation is required") }
        it { expect { subject }.to change(Service, :count).by(0) }
      end

      context "when user confirmed they will update the message" do
        let(:message_update_confirmation) { 1 }

        shared_examples :service_creation do
          it "redirects to the admin" do
            expect(response).to redirect_to(admin_path)
          end

          it "saves the service" do
            expect(Service.last).to have_attributes(
              service_params.excluding(:message_update_confirmation)
            )
          end

          it "uses the given scope" do
            expect(Service.last.scope).to eq(scope)
          end

          it "displays the new service in the dashboard" do
            follow_redirect!
            expect(response.body).to include("Test service")
          end
        end

        context "when the scope is external" do
          let(:scope) { "external" }

          include_examples :service_creation
        end

        context "when the scope is internal" do
          let(:scope) { "internal" }

          include_examples :service_creation
        end
      end
    end
  end

  describe "GET /admin/services/:id/edit" do
    let(:service) { create(:service) }

    before do
      sign_in(user) if authenticated
      get "/admin/services/#{service.id}/edit"
    end

    context "when user is not authenticated" do
      let(:authenticated) { false }

      it { expect(response).to redirect_to(new_user_session_url) }
    end

    context "when user is authenticated" do
      let(:authenticated) { true }

      it { expect(response).to have_http_status(:success) }
      it { expect(response.body).to include("Editing") }
    end
  end

  describe "PATCH /admin/services/:id" do
    let!(:service) { create(:service) }
    let(:service_params) do
      {
        name: "New name",
        status: "Minor Issues",
        hidden: false,
        message_update_confirmation: 1,
        mirror_status_confirmation: nil
      }
    end

    before do
      sign_in(user) if authenticated
      patch "/admin/services/#{service.id}", params: { service: service_params }
    end

    context "when user is not authenticated" do
      let(:authenticated) { false }

      it { expect(response).to redirect_to(new_user_session_url) }
    end

    context "when user is authenticated" do
      let(:authenticated) { true }

      it "redirects to the admin" do
        expect(response).to redirect_to(admin_path)
      end

      it "updates the service" do
        expect(Service.last).to have_attributes(
          service_params.excluding(:message_update_confirmation)
        )
      end
    end
  end

  describe "DELETE /admin/services/:id" do
    let(:service) { create(:service) }
    let(:delete_confirmation) { 1 }

    before do
      sign_in(user) if authenticated
      delete "/admin/services/#{service.id}", params: { service: { delete_confirmation: } }
    end

    context "when user is not authenticated" do
      let(:authenticated) { false }

      it { expect(response).to redirect_to(new_user_session_url) }
    end

    context "when user is authenticated" do
      let(:authenticated) { true }

      context "when user does not confirm deletion" do
        let(:delete_confirmation) { 0 }

        it { expect(response.body).to include("confirmation is required") }

        it "does not delete the service" do
          expect(Service.last).to eq(service)
        end
      end

      context "when user confirms deletion" do
        let(:delete_confirmation) { 1 }

        it "redirects to the admin" do
          expect(response).to redirect_to(admin_path)
        end

        it "flashes a message" do
          follow_redirect!
          expect(response.body).to include("successfully deleted")
        end

        it "deletes the service" do
          expect(Service.last).to eq(nil)
        end
      end
    end
  end
end
