# frozen_string_literal: true

module Users
  class ConfirmationsController < Devise::ConfirmationsController
    # GET /admin/confirmation/new
    def new
      not_found
    end

    # POST /admin/confirmation

    # GET /admin/confirmation?confirmation_token=abcdef

    protected

    def after_confirmation_path_for(_resource_name, resource)
      token = resource.send(:set_reset_password_token)
      edit_password_path(resource, reset_password_token: token)
    end
  end
end
