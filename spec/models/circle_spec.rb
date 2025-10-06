require 'rails_helper'

RSpec.describe Circle, type: :model do
  context "validations" do
    it { should validate_presence_of(:x) }
    it { should validate_presence_of(:y) }
    it { should validate_presence_of(:diameter) }
    it { should validate_numericality_of(:diameter).is_greater_than(0) }
  end

  context "associations" do
    it { should belong_to(:frame) }
  end

  context "#radius" do
    it "returns half of the diameter" do
      circle = build(:circle, diameter: 10)

      expect(circle.radius).to eq(5)
    end
  end

  context "fits_within_frame" do
    let!(:frame) { create(:frame) }

    it "valid when circle fits within frame (could touch the boundary)" do
      circle = build(:circle, frame: frame, x: 0.0, y: 0.0, diameter: 2)

      expect(circle).to be_valid
    end

    it "invalid when circle exceeds frame boundaries" do
      circle = build(:circle, frame: frame, x: 5.0, y: 0.0, diameter: 2)

      expect(circle).not_to be_valid
      expect(circle.errors[:base]).to include("Circle exceeds frame boundaries")
    end
  end

  context "#does_not_touch_other_circles" do
    let!(:frame) { create(:frame) }
    let!(:prev_circle) { create(:circle, frame: frame) }

    it "valid when not touching another circle" do
      circle = build(:circle, frame: frame, x: -2.0, y: -2.0, diameter: 2.0)

      expect(circle).to be_valid
    end

    it "invalid when touching another circle" do
      circle = build(:circle, frame: frame, x: 4.0, y: 2.0, diameter: 2.0)

      expect(circle).not_to be_valid
      expect(circle.errors[:base]).to include("Circle touches another circle or overlap")
    end

    it "invalid when overlapping another circle" do
      circle = build(:circle, frame: frame, x: 3.0, y: 2.0, diameter: 2.0)

      expect(circle).not_to be_valid
      expect(circle.errors[:base]).to include("Circle touches another circle or overlap")
    end
  end
end
