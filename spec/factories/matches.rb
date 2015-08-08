FactoryGirl.define do
  factory :match do
    teams { [create(:team, :team_1), create(:team, :team_2)] }
  end
end
