# frozen_string_literal: true

FactoryBot.define do
  factory :service do
    scope { "external" }
    sequence(:name) { |n| "Test service #{n}" }
    status { "Good Service" }
    hidden { false }
    destroyable { true }
    mirrorable { false }

    trait :external do
      scope { "external" }
      name { "Test service external" }
    end

    trait :internal do
      scope { "internal" }
      name { "Test service internal" }
    end
  end
end
