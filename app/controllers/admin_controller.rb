# frozen_string_literal: true

class AdminController < ApplicationController
  layout "admin"

  include HasSummary

  before_action :switch_scope, only: :switch_dashboard

  def index
    @summary = build_summary(
      scope: session[:scope],
      with_updated_by: true,
      with_hidden_services: true
    )
  end

  def switch_dashboard
    redirect_to admin_path
  end

  private

  def switch_scope
    session[:scope] = new_scope
  end

  def new_scope
    return "internal" if session[:scope] == "external"
    return "external" if session[:scope] == "internal"

    "external"
  end
end
