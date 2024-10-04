# frozen_string_literal: true

class Service < ApplicationRecord
  include HasScope
  include HasScopedLastUpdate

  STATUS_GOOD_SERVICE = "Good Service"
  STATUS_MINOR_ISSUES = "Minor Issues"
  STATUS_SEVERE_ISSUES = "Severe Issues"
  STATUS_SCHEDULED_OUTAGE = "Scheduled Outage"

  ALL_STATUSES = [
    STATUS_GOOD_SERVICE,
    STATUS_MINOR_ISSUES,
    STATUS_SEVERE_ISSUES,
    STATUS_SCHEDULED_OUTAGE
  ].freeze

  scope :visible, -> { where(hidden: false) }
  scope :external, -> { where(scope: "external") }

  validates :name, :status, presence: true
  validates :name, length: { maximum: 25 }, uniqueness: { scope: :scope }
  validates :status, inclusion: { in: ALL_STATUSES }
  validates :hidden, inclusion: { in: [ true, false ] }

  belongs_to :updated_by, class_name: :User

  after_create_commit :broadcast_message
  after_save_commit :broadcast_last_update

  def broadcast_message
    broadcast_replace_to(
      "services-#{scope}",
      partial: "dashboard/services",
      locals: { services: Service.where(scope:).visible.order(name: :asc) },
      target: "services"
    )
  end

  def broadcast_last_update
    broadcast_replace_to(
      "last_update-#{scope}",
      partial: "dashboard/last_update",
      locals: { last_update: Service.new(updated_at:) },
      target: "last_update"
    )
  end
end
