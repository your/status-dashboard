# frozen_string_literal: true

module AdminHelper
  def services_to_summary_data(services)
    services.reduce([]) do |memo, service|
      memo << build_service_summary(service)
    end
  end

  private

  def build_service_summary(service)
    {
      key: { text: service.name },
      value: {
        text: build_service_status(service),
        classes: build_service_classes(service)
      },
      actions: build_service_actions(service)
    }
  end

  def build_service_status(service)
    return service.status unless service.hidden

    "(hidden) #{service.status}"
  end

  def build_service_classes(service)
    classes = [ "status" ]
    classes << if service.hidden == true
                 "status--hidden"
    else
                 "status--#{service.status.downcase.parameterize(separator: '-')}"
    end
  end

  def build_service_actions(service)
    actions = %i[change delete].map do |action|
      {
        text: action.capitalize.to_s,
        href: build_action_service_link(action, service),
        visually_hidden_text: "#{action.capitalize} #{service.name}",
        classes: [ "govuk-link--no-visited-state" ]
      }
    end
    return actions if service.destroyable?

    actions << actions.pop.merge(classes: [ "govuk-link--no-visited-state disabled" ])
  end

  def build_action_service_link(action, service)
    case action
    when :change
      edit_service_path(id: service.id)
    when :delete
      delete_service_path(id: service.id)
    end
  end
end
