# frozen_string_literal: true

class UsersController < ApplicationController
  layout "admin"

  before_action :restrict_to_admin, only: %i[index new create delete destroy]
  before_action :verify_permission, only: %i[show edit update]

  before_action :find_user, only: %i[show edit update delete destroy]
  before_action :mark_user_for_deletion, only: :destroy

  def index
    @users = User.order(id: :desc)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.skip_password_validation = true

    if @user.save
      redirect_to users_path, notice: t(".success", email: @user.email)
    else
      render :new
    end
  end

  def show; end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to users_path, notice: t(".success", email: @user.email)
    else
      render :edit
    end
  end

  def delete; end

  def destroy
    unless @user.valid?
      render :delete
      return
    end

    if @user.destroy
      redirect_to users_path, notice: t(".success", email: @user.email)
    else
      redirect_to users_path, alert: t(".failure", email: @user.email)
    end
  end

  private

  def find_user
    @user = User.find(params[:id])
  end

  def user_params
    attrs = %i[name email]
    attrs << %i[password password_confirmation] unless params[:user][:password].blank?
    attrs << :admin if current_user.admin?
    params.require(:user).permit(*attrs)
  end

  def mark_user_for_deletion
    @user.marked_for_deletion = true
    @user.delete_confirmation = delete_params
  end

  def delete_params
    params.dig(:user, :delete_confirmation)
  end

  def restrict_to_admin
    redirect_to admin_path unless current_user.admin?
  end

  def verify_permission
    return if current_user.admin? || params[:id] == current_user.id.to_s

    redirect_to admin_path, alert: t("unauthorised")
  end
end
