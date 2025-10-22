# frozen_string_literal: true

FactoryBot.define do
  factory :reading do
    user
    book
    reason { 'This book looks interesting.' }
    status { :wish }
    wish_date { Date.current }

    trait :tsundoku do
      status { :tsundoku }
      tsundoku_date { Date.current }
    end

    trait :completed do
      status { :completed }
      tsundoku_date { 1.month.ago.to_date }
      completed_date { Date.current }
    end
  end
end
