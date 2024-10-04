# frozen_string_literal: true

class MessagesController < ApplicationController
  layout "admin"

  def create
    @message = Message.new(message_params)

    if @message.save
      redirect_to admin_path, notice: t(".success")
    else
      redirect_to admin_path, alert: t(".failure", error: error_message)
    end
  end

  private

  def message_params
    params
      .require(:message)
      .permit(:body)
      .merge!(scope: session[:scope], updated_by_id: current_user.id)
  end

  def error_message
    @message.errors.full_messages.join("; ")
  end
end
