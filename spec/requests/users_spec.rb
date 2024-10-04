# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users", type: :request do
  let(:user) { create(:user) }
  let!(:other_users) { create_list(:user, 3) }
  let(:another_user) { other_users.first }

  describe "GET /admin/users/new" do
    before do
      sign_in(user) if authenticated
      get "/admin/users/new"
    end

    context "when user is not authenticated" do
      let(:authenticated) { false }

      it { expect(response).to redirect_to(new_user_session_url) }
    end

    context "when user is authenticated" do
      let(:authenticated) { true }

      context "when the user is admin" do
        let(:user) { create(:user, :admin) }

        it { expect(response).to have_http_status(:success) }
        it { expect(response.body).to include("Add new user") }
      end

      context "when the user is not admin" do
        let(:user) { create(:user, :non_admin) }

        it { expect(response).to redirect_to(admin_path) }
      end
    end
  end

  describe "GET /admin/users" do
    before do
      sign_in(user) if authenticated
      get "/admin/users"
    end

    context "when user is not authenticated" do
      let(:authenticated) { false }

      it { expect(response).to redirect_to(new_user_session_url) }
    end

    context "when user is authenticated" do
      let(:authenticated) { true }

      context "when the user is admin" do
        let(:user) { create(:user, :admin) }

        it { expect(response).to have_http_status(:success) }
        it { expect(response.body).to include("Users") }

        it "lists all the users" do
          expect(response.body).to include(*other_users.map(&:name))
        end
      end

      context "when the user is not admin" do
        let(:user) { create(:user, :non_admin) }

        it { expect(response).to redirect_to(admin_path) }

        it "does not lists all the users" do
          follow_redirect!
          expect(response.body).not_to include(*other_users.map(&:name))
        end
      end
    end
  end

  describe "GET /admin/users/:id" do
    before do
      sign_in(user) if authenticated
      get "/admin/users/#{another_user.id}"
    end

    context "when user is not authenticated" do
      let(:authenticated) { false }

      it { expect(response).to redirect_to(new_user_session_url) }
    end

    context "when user is authenticated" do
      let(:authenticated) { true }

      context "when the user is admin" do
        let(:user) { create(:user, :admin) }

        it "they can see another user profile", :aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(response.body).to include("User profile")
          expect(response.body).to include(another_user.name)
          expect(response.body).to include(another_user.email)
        end
      end

      context "when the user is not admin" do
        let(:user) { create(:user, :non_admin) }

        it "are redirected to the admin page" do
          expect(response).to redirect_to(admin_path)
        end

        it "shows an unauthorised error" do
          follow_redirect!
          expect(response.body).to include("Unauthorised to perform this action")
        end
      end
    end
  end

  describe "GET /admin/users/:id/edit" do
    before do
      sign_in(user) if authenticated
      get "/admin/users/#{another_user.id}/edit"
    end

    context "when user is not authenticated" do
      let(:authenticated) { false }

      it { expect(response).to redirect_to(new_user_session_url) }
    end

    context "when user is authenticated" do
      let(:authenticated) { true }

      context "when the user is admin" do
        let(:user) { create(:user, :admin) }

        it { expect(response).to have_http_status(:success) }
        it { expect(response.body).to include("Edit user") }
      end
    end
  end

  describe "PATCH /admin/users/:id" do
    before do
      sign_in(user) if authenticated
      patch "/admin/users/#{another_user.id}", params: { user: { name: "New Name" } }
    end

    context "when user is not authenticated" do
      let(:authenticated) { false }

      it { expect(response).to redirect_to(new_user_session_url) }
    end

    context "when user is authenticated" do
      let(:authenticated) { true }

      context "when the user is admin" do
        let(:user) { create(:user, :admin) }

        it "updates the user" do
          expect(another_user.reload.name).to eq("New Name")
        end

        it { expect(response).to redirect_to(users_path) }

        it "shows a success message" do
          follow_redirect!
          expect(response.body).to include("updated")
        end
      end
    end
  end

  describe "DELETE /admin/users/:id" do
    let(:confirmation) { "1" }

    before do
      sign_in(user) if authenticated
      delete "/admin/users/#{another_user.id}", params: { user: { delete_confirmation: confirmation } }
    end

    context "when user is not authenticated" do
      let(:authenticated) { false }

      it { expect(response).to redirect_to(new_user_session_url) }
    end

    context "when user is authenticated" do
      let(:authenticated) { true }

      context "when the user is admin" do
        let(:user) { create(:user, :admin) }

        context "when the deletion is not confirmed" do
          let(:confirmation) { "0" }

          it { expect(response.body).to include("You are about to delete the following user") }

          it "shows a success error" do
            expect(response.body).to include("confirmation is required")
          end

          it { expect(another_user.reload.deleted?).to eq(false) }
        end

        context "when the deletion is confirmed" do
          let(:confirmation) { "1" }

          it { expect(response).to redirect_to(users_path) }

          it "shows a success message" do
            follow_redirect!
            expect(response.body).to include("successfully deleted")
          end

          it { expect(another_user.reload.deleted?).to eq(true) }
        end
      end

      context "when the user is not admin" do
        let(:user) { create(:user, :non_admin) }

        it { expect(response).to redirect_to(admin_path) }
      end
    end
  end
end
