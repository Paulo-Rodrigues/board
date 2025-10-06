require "rails_helper"

describe FramePresenter do
  context "#as_json" do
    it "returns the correct structure without circles" do
      frame = create(:frame)

      expected = {
        id: frame.id,
        x: frame.x.to_s,
        y: frame.y.to_s,
        width: frame.width.to_s,
        height: frame.height.to_s,
        total_circles: 0
      }

      result = FramePresenter.new(frame).as_json

      expect(result).to eq(expected)
    end

    it "returns the correct structure with circles" do
      frame = create(:frame)
      circle_high = create(:circle, frame: frame, y: 4.0)
      circle_low  = create(:circle, frame: frame, x: 4.0, y: -4.0)
      circle_left = create(:circle, frame: frame, x: -3.0)

      expected = {
        id: frame.id,
        x: frame.x.to_s,
        y: frame.y.to_s,
        width: frame.width.to_s,
        height: frame.height.to_s,
        total_circles: 3,
        highest_circle: {
          id: circle_high.id.to_s,
          x: circle_high.x.to_s,
          y: circle_high.y.to_s
        },
        lowest_circle: {
          id: circle_low.id.to_s,
          x: circle_low.x.to_s,
          y: circle_low.y.to_s
        },
        leftmost_circle: {
          id: circle_left.id.to_s,
          x: circle_left.x.to_s,
          y: circle_left.y.to_s
        },
        rightmost_circle: {
          id: circle_low.id.to_s,
          x: circle_low.x.to_s,
          y: circle_low.y.to_s
        }
      }

      result = FramePresenter.new(frame).as_json

      expect(result).to eq(expected)
    end
  end
end
