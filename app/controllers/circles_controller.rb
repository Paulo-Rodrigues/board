class CirclesController < ApplicationController
  def update
    circle = Circle.find(params[:id])

    if circle.update(circle_params)
      render json: { circle: circle }, status: :ok
    else
      render json: { errors: circle.errors.full_messages }, status: :unprocessable_entity
    end

  rescue ActiveRecord::RecordNotFound
    render json: { error: "Circle not found" }, status: :not_found
  end

  def destroy
    circle = Circle.find(params[:id])

    if circle.destroy
      head :no_content
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Circle not found" }, status: :not_found
  end

  private

  def circle_params
    params.require(:circle).permit(:x, :y, :diameter)
  end
end
