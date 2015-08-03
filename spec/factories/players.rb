FactoryGirl.define do
  factory :player do
    name 'Managed by Q'
    email 'managed@q.com'
    password 'password'
    password_confirmation 'password'

    trait :baller_bank do
      name 'Baller Bank'
      email 'baller@bank.com'
    end

    trait :mean_greene do
      name 'Mean Greene'
      email 'mean@greene.com'
    end

    trait :rusty_raymond do
      name 'Rusty Raymond'
      email 'rusty@raymond.com'
    end
  end
end