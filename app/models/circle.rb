class Circle < ApplicationRecord
  belongs_to :frame

  validates :x, :y, :diameter, presence: true
  validates :diameter, numericality: { greater_than: 0 }
  validate :fits_within_frame
  validate :does_not_touch_other_circles

  scope :within_area, ->(center_x:, center_y:, radius:) {
    where(
      "SQRT(POW(x - ?, 2) + POW(y - ?, 2)) + (diameter / 2.0) <= ?",
      center_x, center_y, radius
    )
  }

  def radius = diameter / 2.0

  private

  def fits_within_frame
    return unless frame && x.present? && y.present? && diameter.present?

    if x - radius < frame.left || x + radius > frame.right || y - radius < frame.bottom || y + radius > frame.top
      errors.add(:base, "Circle exceeds frame boundaries")
    end
  end

  def does_not_touch_other_circles
    return unless frame

    frame.circles.where.not(id: id).find_each do |other_circle|
      dx = x - other_circle.x
      dy = y - other_circle.y
      distance = Math.sqrt(dx**2 + dy**2)
      min_distance = radius + other_circle.radius

      if distance < (min_distance * min_distance)
        errors.add(:base, "Circle touches another circle or overlap")
        break
      end
    end
  end
end
