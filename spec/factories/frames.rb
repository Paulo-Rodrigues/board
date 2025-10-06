FactoryBot.define do
  factory :frame do
    x { 0.00 }
    y { 0.00 }
    width { 10.00 }
    height { 10.00 }

    trait :with_circles do
      after(:create) do |frame|
        create(:circle, frame: frame)
      end
    end
  end
end
