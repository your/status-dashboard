# frozen_string_literal: true

module HasSummary
  extend ActiveSupport::Concern

  Summary = Struct.new(:message, :last_update)

  def build_summary(scope:)
    Summary.new(
      fetch_message(scope),
      fetch_last_update(scope)
    )
  end

  private

  def fetch_message(scope)
    Message.where(scope:).last || Message.new
  end

  def fetch_last_update(scope)
    Message.last_update_by_scope(scope)
  end
end
