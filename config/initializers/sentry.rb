# frozen_string_literal: true

Rails.application.config.to_prepare do
  Sentry.init do |config|
    config.breadcrumbs_logger = %i[active_support_logger http_logger]
    config.environment = Rails.env

    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)

    config.before_send = lambda do |event, hint|
      event.fingerprint = [ "database-unavailable" ] if hint[:exception].is_a?(ActiveRecord::ConnectionNotEstablished)

      filter.filter(event.to_hash)
    end

    config.traces_sample_rate = 0.2
  end
end
