# frozen_string_literal: true

FactoryBot.define do
  factory :message do
    scope { "external" }
    body { "This is a test message" }
  end
end
