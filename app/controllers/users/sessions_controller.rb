# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    # GET /admin/login

    # POST /admin/login

    # DELETE /admin/logout

    protected

    def after_sign_in_path_for(_resource)
      admin_path
    end

    def after_sign_out_path_for(_resource)
      new_user_session_path
    end
  end
end
