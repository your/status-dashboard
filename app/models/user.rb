# frozen_string_literal: true

class User < ApplicationRecord
  acts_as_paranoid

  attr_accessor :marked_for_deletion, :delete_confirmation, :skip_password_validation

  EMAIL_FORMAT_REGEX = /\A[\w+.-]+@changeme\.com/i
  PASSWORD_COMPLEXITY_REGEX = /^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{15,70}$/

  devise :password_archivable, :session_limitable
  devise :database_authenticatable, :confirmable, :recoverable,
         :rememberable, :validatable, :trackable, :timeoutable, :lockable

  validates :name, presence: true
  validates :email, format: { with: EMAIL_FORMAT_REGEX, message: :invalid_domain }
  validates :delete_confirmation,
            inclusion: { in: [ "1" ], message: "confirmation is required" },
            if: -> { marked_for_deletion == true }
  validate :password_complexity, on: :update

  def admin?
    admin == true
  end

  protected

  def password_required?
    return false if skip_password_validation

    super
  end

  private

  def password_complexity
    return if password.blank? || password =~ PASSWORD_COMPLEXITY_REGEX

    errors.add(:password, :insufficient_complexity)
  end
end
