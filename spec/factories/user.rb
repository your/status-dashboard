# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "John Doe #{n}" }
    sequence(:email) { |n| "john.doe#{n}@changeme.com" }
    password { 'DummyDummyPwd01' }
    password_confirmation { 'DummyDummyPwd01' }
    confirmed_at { DateTime.now }
    admin { false }

    trait :admin do
      admin { true }
    end

    trait :non_admin do
      admin { false }
    end

    trait :deleted do
      deleted_at { DateTime.now }
    end

    trait :with_simple_password do
      password { 'SimplePass' }
    end

    trait :without_password do
      password { nil }
    end

    trait :not_confirmed do
      before(:create) do |user, _|
        user.skip_confirmation!
      end
    end

    trait :with_reset_token do
      reset_password_token { 'foobar' }
      reset_password_sent_at { DateTime.now }
    end
  end
end
