class Frame < ApplicationRecord
  has_many :circles, dependent: :restrict_with_error

  accepts_nested_attributes_for :circles, allow_destroy: true

  validates :x, :y, :width, :height, presence: true
  validate :cannot_touch_or_overlap_other_frames

  DIVIDER = 2.0

  def top = y + (height / DIVIDER)
  def bottom = y - (height / DIVIDER)
  def left = x - (width / DIVIDER)
  def right = x + (width / DIVIDER)

  def total_circles = circles.count
  def highest_circle = circles.order(y: :desc).first
  def lowest_circle = circles.order(y: :asc).first
  def leftmost_circle = circles.order(x: :asc).first
  def rightmost_circle = circles.order(x: :desc).first

  private

  def cannot_touch_or_overlap_other_frames
    Frame.where.not(id: id).find_each do |other|
      unless right < other.left || left > other.right || top < other.bottom || bottom > other.top
        errors.add(:base, "cannot touch or overlap other frames")
        break
      end
    end
  end
end
