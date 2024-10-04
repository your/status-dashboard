# frozen_string_literal: true

module Users
  class UnlocksController < Devise::UnlocksController
    # GET /admin/unlock/new
    def new
      not_found
    end

    # POST /admin/unlock

    # GET /admin/unlock?unlock_token=abcdef
  end
end
