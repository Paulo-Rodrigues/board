FactoryBot.define do
  factory :circle do
    x { 2.00 }
    y { 2.00 }
    diameter { 2.00 }
    association :frame
  end
end
