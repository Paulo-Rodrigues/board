class FramesController < ApplicationController
  def create
    frame = Frame.new(frame_params)

    if frame.save
      render json: { frame: frame }, status: :created
    else
      render json: { errors: frame.errors.full_messages }, status: :unprocessable_content
    end
  end

  def show
    frame = Frame.find(params[:id])

    result = FramePresenter.new(frame).as_json

    render json: { frame: result }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Frame not found" }, status: :not_found
  end

  def destroy
    frame = Frame.find(params[:id])

    if frame.destroy
      head :no_content
    else
      render json: { error: "Cannot delete frame with associated circles" }, status: :unprocessable_content
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Frame not found" }, status: :not_found
  end

  private

  def frame_params
    params.require(:frame).permit(
      :x, :y, :width, :height,
      circles_attributes: [ :x, :y, :diameter ]
    )
  end
end
