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

  attr_accessor :marked_for_update, :message_update_confirmation, :marked_for_deletion, :delete_confirmation,
  :mirror_status_confirmation, :skip_broadcast_changes

  validates :name, :status, presence: true
  validates :name, length: { maximum: 25 }, uniqueness: { scope: :scope }
  validates :status, inclusion: { in: ALL_STATUSES }
  validates :hidden, inclusion: { in: [ true, false ] }
  validates :delete_confirmation,
            inclusion: { in: [ "1" ], message: "confirmation is required" },
            if: -> { marked_for_deletion == true }
  validates :message_update_confirmation,
            inclusion: { in: [ "1" ], message: "confirmation is required" },
            if: -> { marked_for_update == true }
  validates :mirror_status_confirmation,
            inclusion: { in: %w[0 1] },
            if: -> { mirrorable? && marked_for_update == true }
  validate :allow_mirror_status?, if: -> { mirror_status_confirmation == "1" }
  validate :allow_destroy?, if: -> { marked_for_deletion == true }

  belongs_to :updated_by, class_name: :User

  after_create_commit :broadcast_message
  after_save_commit :broadcast_last_update

  def good_service?
    status == STATUS_GOOD_SERVICE
  end

  def destroyable?
    destroyable == true
  end

  def mirrorable?
    mirrorable == true
  end

  private

  def allow_mirror_status?
    return unless mirrorable?
    return if MIRRORABLE_STATUSES.include?(status)

    errors.add(:mirror_status_confirmation, :cannot_delete, statuses: MIRRORABLE_STATUSES.join(", "))
  end

  def allow_destroy?
    errors.add(:delete_confirmation, :cannot_delete) unless destroyable?
  end

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
