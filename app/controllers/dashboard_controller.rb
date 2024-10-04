# frozen_string_literal: true

class DashboardController < ApplicationController
  include HasSummary

  skip_before_action :authenticate_user!, only: :index
  skip_before_action :set_session_scope, only: :index

  before_action :determine_scope, only: :index
  before_action :determine_variant, only: :index
  before_action :embeddable_action, only: :index

  def index
    @summary = build_summary(scope: @scope)

    fresh_when etag: @summary.last_update
  end

  private

  def determine_scope
    case params[:scope]
    when nil
      @scope = "external"
    when "internal"
      @scope = "internal"
    when "external"
      redirect_to dashboard_path
    else
      not_found
    end
  end

  def determine_variant
    request.variant = :embedded if params[:embedded]
  end

  def embeddable_action
    response.headers.delete("X-Frame-Options")
  end
end
