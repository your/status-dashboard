# frozen_string_literal: true

FactoryBot.define do
  factory :message do
    updated_by factory: :user

    scope { "external" }
    body { "This is a test message" }
  end
end
