class CirclesController < ApplicationController
  def index
    render json: { circles: filtered_circles }, status: :ok
  end

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

  def filtered_circles
    return [] unless valid_search_params?

    scope.within_area(**search_params)
  end

  def scope
    if params[:frame_id].present?
      Circle.where(frame_id: params[:frame_id])
    else
      Circle.all
    end
  end

  def search_params
    {
      center_x: params[:center_x].to_f,
      center_y: params[:center_y].to_f,
      radius: params[:radius].to_f
    }
  end

  def valid_search_params?
    params[:center_x].present? &&
    params[:center_y].present? &&
    params[:radius].present? &&
    params[:radius].to_f > 0
  end

  def circle_params
    params.require(:circle).permit(:x, :y, :diameter)
  end
end
