# frozen_string_literal: true

class Message < ApplicationRecord
  include HasScope
  include HasScopedLastUpdate

  before_update :must_prevent_update?
  before_destroy :must_prevent_destroy?

  after_create_commit :broadcast_message
  after_save_commit :broadcast_last_update

  private

  def must_prevent_update?
    return if new_record?

    errors.add(:base, :cannot_update)
    throw(:abort)
  end

  def must_prevent_destroy?
    errors.add(:base, :cannot_delete)
    throw(:abort)
  end

  def broadcast_message
    broadcast_replace_to(
      "message-#{scope}",
      partial: "dashboard/message",
      target: "message",
      locals: { message: self }
    )
  end

  def broadcast_last_update
    broadcast_replace_to(
      "last_update-#{scope}",
      partial: "dashboard/last_update",
      target: "last_update",
      locals: { last_update: Message.new(updated_at:) }
    )
  end
end
