# frozen_string_literal: true

class ServicesController < ApplicationController
  layout "admin"

  before_action :find_service, only: %i[edit update delete destroy]
  before_action :mark_service_for_deletion, only: :destroy

  def new
    @service = Service.new
  end

  def create
    @service = Service.new(service_params)
    @service.marked_for_update = true

    if @service.save
      mirror_status_if_requested
      redirect_to admin_path, notice: t(".success", name: @service.name)
    else
      render :new
    end
  end

  def edit; end

  def update
    @service.marked_for_update = true

    if @service.update(service_params)
      mirror_status_if_requested
      redirect_to admin_path, notice: t(".success", name: @service.name)
    else
      render :edit
    end
  end

  def delete; end

  def destroy
    unless @service.valid?
      render :delete
      return
    end

    if @service.destroy
      redirect_to admin_path, notice: t(".success", name: @service.name)
    else
      redirect_to admin_path, alert: t(".failure", name: @service.name)
    end
  end

  private

  def find_service
    @service = Service.where(scope: session[:scope]).find(params[:id])
  end

  def service_params
    params
      .require(:service)
      .permit(:name, :status, :hidden, :message_update_confirmation, :mirror_status_confirmation)
      .merge!(scope: session[:scope], updated_by_id: current_user.id)
  end

  def mark_service_for_deletion
    @service.marked_for_deletion = true
    @service.delete_confirmation = delete_params
  end

  def delete_params
    params.dig(:service, :delete_confirmation)
  end

  def mirror_status_if_requested
    return unless service_params[:mirror_status_confirmation] == "1"

    Service.visible.update(status: @service.status, updated_by: current_user)
  end
end
