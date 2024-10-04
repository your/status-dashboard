# frozen_string_literal: true

module HasSummary
  extend ActiveSupport::Concern

  Summary = Struct.new(:message, :services, :last_update)

  def build_summary(scope:, with_updated_by: false, with_hidden_services: false)
    Summary.new(
      fetch_message(scope),
      fetch_services(scope, with_hidden_services),
      fetch_last_update(scope, with_updated_by)
    )
  end

  private

  def fetch_message(scope)
    Message.where(scope:).last || Message.new
  end

  def fetch_services(scope, with_hidden_services)
    query = Service.where(scope:)
    query = query.visible unless with_hidden_services
    query.order(name: :asc)
  end

  def fetch_last_update(scope, with_updated_by)
    [
      Service.last_update_by_scope(scope, with_updated_by:),
      Message.last_update_by_scope(scope, with_updated_by:)
    ].compact.select(&:updated_at).max_by(&:updated_at)
  end
end
