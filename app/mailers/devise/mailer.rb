# frozen_string_literal: true

module Devise
  class Mailer < GovukNotifyRails::Mailer
    include Devise::Controllers::UrlHelpers
    include ActionView::Helpers::DateHelper

    GOVUK_NOTIFY_TEMPLATES = {
      confirmation_instructions: "CHANGEME-1",
      reset_password_instructions: "CHANGEME-2",
      password_change: "CHANGEME-3",
      unlock_instructions: "CHANGEME-4"
    }.freeze

    def confirmation_instructions(user, token, _opts = {})
      set_template(GOVUK_NOTIFY_TEMPLATES[:confirmation_instructions])
      set_personalisation(
        user_name: user.name,
        confirmation_url: confirmation_url(user, confirmation_token: token),
        token_expiry_period: distance_of_time_in_words(User.confirm_within)
      )
      mail(to: user.email)
    end

    def reset_password_instructions(user, token, _opts = {})
      set_template(GOVUK_NOTIFY_TEMPLATES[:reset_password_instructions])
      set_personalisation(
        user_name: user.name,
        user_email: user.email,
        edit_password_url: edit_password_url(user, reset_password_token: token),
        token_expiry_period: distance_of_time_in_words(User.reset_password_within)
      )
      mail(to: user.email)
    end

    def password_change(user, _opts = {})
      set_template(GOVUK_NOTIFY_TEMPLATES[:password_change])
      set_personalisation(
        user_name: user.name
      )
      mail(to: user.email)
    end

    def unlock_instructions(user, token, _opts = {})
      set_template(GOVUK_NOTIFY_TEMPLATES[:unlock_instructions])
      set_personalisation(
        user_name: user.name,
        unlock_url: unlock_url(user, unlock_token: token),
        reset_password_url: new_password_path(user)
      )
      mail(to: user.email)
    end
  end
end
