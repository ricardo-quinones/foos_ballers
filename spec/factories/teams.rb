FactoryGirl.define do
  factory :team do
    trait :team_1 do
      players { [create(:player), create(:player, :baller_bank)] }
    end

    trait :team_2 do
      players { [create(:player, :mean_greene), create(:player, :rusty_raymond)] }
    end
  end
end
