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

  context ".within_area" do
    let!(:large_frame) { create(:frame, x: 0, y: 0, width: 20, height: 20) }

    let!(:circle_inside) { create(:circle, frame: large_frame, x: 1.0, y: 1.0, diameter: 1.0) }
    let!(:circle_outside) { create(:circle, frame: large_frame, x: 8.0, y: 8.0, diameter: 1.0) }
    let!(:circle_touching_boundary) { create(:circle, frame: large_frame, x: 4.0, y: 0.0, diameter: 2.0) }

    it "returns circles completely within the search area" do
      result = Circle.within_area(center_x: 0, center_y: 0, radius: 3)

      expect(result).to include(circle_inside)
      expect(result).not_to include(circle_outside)
    end

    it "returns circles that touch the boundary of the search area" do
      result = Circle.within_area(center_x: 0, center_y: 0, radius: 5)

      expect(result).to include(circle_touching_boundary)
    end

    it "returns empty result when no circles match" do
      result = Circle.within_area(center_x: 100, center_y: 100, radius: 1)

      expect(result).to be_empty
    end

    it "handles zero radius search area" do
      result = Circle.within_area(center_x: 1.0, center_y: 1.0, radius: 0)

      expect(result).to be_empty
    end

    it "works with decimal coordinates" do
      separate_frame = create(:frame, x: 25, y: 25, width: 10, height: 10)
      circle = create(:circle, frame: separate_frame, x: 27.0, y: 28.0, diameter: 1.0)

      result = Circle.within_area(center_x: 27.0, center_y: 28.0, radius: 2.0)

      expect(result).to include(circle)
    end
  end
end
