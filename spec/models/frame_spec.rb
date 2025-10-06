require 'rails_helper'

RSpec.describe Frame, type: :model do
  context "validations" do
    it { should validate_presence_of(:x) }
    it { should validate_presence_of(:y) }
    it { should validate_presence_of(:width) }
    it { should validate_presence_of(:height) }
  end

  context "associations" do
    it { should have_many(:circles).dependent(:restrict_with_error) }
  end

  context "top, botton, left, right methods" do
    let(:frame) { create(:frame) }

    it "#top" do
      expect(frame.top).to eq(frame.y + (frame.height / 2.0))
    end

    it "#bottom" do
      expect(frame.bottom).to eq(frame.y - (frame.height / 2.0))
    end

    it "#left" do
      expect(frame.left).to eq(frame.x - (frame.width / 2.0))
    end

    it "#right" do
      expect(frame.right).to eq(frame.x + (frame.width / 2.0))
    end
  end

  context "cannot touch other frames or overlap" do
    let!(:ref_frame) { create(:frame) }

    it "valid without overlap" do
      other = build(:frame, x: 20.0)

      expect(other).to be_valid
    end

    it "cannot touch on the left" do
      other = build(:frame, x: -10.0)

      expect(other).not_to be_valid
      expect(other.errors[:base]).to include("cannot touch or overlap other frames")
    end

    it "cannot touch on the right" do
      other = build(:frame, x: 10.0)

      expect(other).not_to be_valid
      expect(other.errors[:base]).to include("cannot touch or overlap other frames")
    end

    it "cannot touch on the top" do
      other = build(:frame, y: 10.0)

      expect(other).not_to be_valid
      expect(other.errors[:base]).to include("cannot touch or overlap other frames")
    end

    it "cannot touch on the bottom" do
      other = build(:frame, y: -10.0)

      expect(other).not_to be_valid
      expect(other.errors[:base]).to include("cannot touch or overlap other frames")
    end
  end

  context "accepts_nested_attributes_for :circles" do
    it "accepts nested attributes for circles" do
      expect(Frame.new).to respond_to(:circles_attributes=)
    end

    it "creates circles through nested attributes" do
      frame_params = {
        x: 0.0,
        y: 0.0,
        width: 10.0,
        height: 10.0,
        circles_attributes: [
          { x: 1.0, y: 1.0, diameter: 2.0 },
          { x: -2.0, y: -2.0, diameter: 2.0 }
        ]
      }

      frame = Frame.create(frame_params)

      expect(frame).to be_persisted
      expect(frame.circles.count).to eq(2)
    end

    it "fails to create when circles are invalid" do
      frame_params = {
        x: 0.0,
        y: 0.0,
        width: 10.0,
        height: 10.0,
        circles_attributes: [
          { x: 1.0, y: 1.0, diameter: 2.0 },
          { x: nil, y: -2.0, diameter: 2.0 }
        ]
      }

      frame = Frame.create(frame_params)

      expect(frame).not_to be_persisted
      expect(frame.errors.full_messages).to include("Circles x can't be blank")
    end
  end

  context "circle relative positions" do
    let!(:frame) { create(:frame) }
    let!(:circle_high) { create(:circle, frame: frame, y: 4.0) }
    let!(:circle_low)  { create(:circle, frame: frame, x: 4.0, y: -4.0) }
    let!(:circle_left) { create(:circle, frame: frame, x: -3.0) }

    it "total_circles" do
      expect(frame.total_circles).to eq(3)
    end

    it "highest_circle" do
      expect(frame.highest_circle).to eq(circle_high)
    end

    it "lowest_circle" do
      expect(frame.lowest_circle).to eq(circle_low)
    end

    it "leftmost_circle" do
      expect(frame.leftmost_circle).to eq(circle_left)
    end

    it "rightmost_circle" do
      expect(frame.rightmost_circle).to eq(circle_low)
    end

    it "returns nil when no circles" do
      frame = create(:frame, x: 20.0)

      expect(frame.total_circles).to eq(0)
      expect(frame.highest_circle).to be_nil
      expect(frame.lowest_circle).to be_nil
      expect(frame.leftmost_circle).to be_nil
      expect(frame.rightmost_circle).to be_nil
    end
  end
end
