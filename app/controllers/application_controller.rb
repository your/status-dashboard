# frozen_string_literal: true

class ApplicationController < ActionController::Base
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  before_action :set_session_scope

  def not_found
    render file: "#{Rails.root}/public/404.html", status: 404, layout: true
  end

  protected

  def set_session_scope
    session[:scope] ||= 'external'
  end
end
