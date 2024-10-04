# frozen_string_literal: true

module UsersHelper
  def users_to_summary_data(users)
    users.reduce([]) do |memo, user|
      actions = build_user_actions(user)

      memo << {
        key: { text: user.name },
        value: {
          text: user.email
        },
        actions:
      }
    end
  end

  private

  def build_user_actions(user)
    %i[show edit delete].map do |action|
      {
        text: action.capitalize.to_s,
        href: build_action_user_link(action, user),
        visually_hidden_text: "#{action.capitalize} #{user.email}",
        classes: [ "govuk-link--no-visited-state" ]
      }
    end
  end

  def build_action_user_link(action, user)
    case action
    when :show
      user_path(id: user.id)
    when :edit
      edit_user_path(id: user.id)
    when :delete
      delete_user_path(id: user.id)
    end
  end
end
