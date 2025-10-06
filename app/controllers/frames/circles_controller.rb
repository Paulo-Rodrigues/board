class Frames::CirclesController < ApplicationController
  def create
    frame = Frame.find(params[:frame_id])
    circle = frame.circles.new(circle_params)

    if circle.save
      render json: { frame: frame.as_json(include: :circles) }, status: :created
    else
      render json: { errors: circle.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def circle_params
    params.require(:circle).permit(:x, :y, :diameter)
  end
end
