class FramePresenter
  def initialize(frame)
    @frame = frame
  end

  def as_json(*)
    {
      id: frame.id,
      x: frame.x.to_s,
      y: frame.y.to_s,
      width: frame.width.to_s,
      height: frame.height.to_s,
      total_circles: frame.total_circles
    }.merge(circles_infos)
  end

  private

  attr_reader :frame

  def circle_to_hash(circle)
    return nil unless circle

    {
      id: circle.id.to_s,
      x: circle.x.to_s,
      y: circle.y.to_s
    }
  end

  def circles_infos
    return {} if frame.total_circles.zero?

    {
      highest_circle: circle_to_hash(frame.highest_circle),
      lowest_circle: circle_to_hash(frame.lowest_circle),
      leftmost_circle: circle_to_hash(frame.leftmost_circle),
      rightmost_circle: circle_to_hash(frame.rightmost_circle)
    }
  end
end
