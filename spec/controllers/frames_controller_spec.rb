require "rails_helper"

describe FramesController, type: :controller do
  context "POST #create" do
    it "successfully creates a frame" do
      params = {
        x: 10.0,
        y: 10.0,
        width: 10.0,
        height: 10.0
      }

      post :create, params: { frame: params }

      expect(response).to have_http_status(:created)
      expect(json_response[:frame]).to include(x: "10.0", y: "10.0", width: "10.0", height: "10.0")
    end

    it "successfully creates a frame with nested circles attributes" do
      params = {
        x: 10,
        y: 10,
        width: 10,
        height: 10,
        circles_attributes: [
          { x: 12, y: 12, diameter: 2 },
          { x: 8, y: 8, diameter: 2 }
        ]
      }

      post :create, params: { frame: params }

      expect(response).to have_http_status(:created)
      expect(json_response[:frame]).to include(x: "10.0", y: "10.0", width: "10.0", height: "10.0")
    end

    it "unsuccessfully creates a frame with invalid attributes" do
      params = {
        x: nil,
        y: 10.0,
        width: 10.0,
        height: 10.0
      }

      post :create, params: { frame: params }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response[:errors]).to include("X can't be blank")
    end

    it "unsuccessfully creates a frame with invalid nested circles attributes" do
      params = {
        x: 10,
        y: 10,
        width: 10,
        height: 10,
        circles_attributes: [
          { x: 12, y: 12, diameter: 2 },
          { x: nil, y: 8, diameter: 2 }
        ]
      }

      post :create, params: { frame: params }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response[:errors]).to include("Circles x can't be blank")
    end
  end

  context "GET #show" do
    it "successfully retrieves a frame with circles" do
      frame = create(:frame)
      circle_high = create(:circle, frame: frame, y: 4.0)
      circle_low  = create(:circle, frame: frame, x: 4.0, y: -4.0)
      circle_left = create(:circle, frame: frame, x: -3.0)

      get :show, params: { id: frame.id }

      expect(response).to have_http_status(:ok)
      expect(json_response[:frame]).to include(x: "0.0", y: "0.0", width: "10.0", height: "10.0")
      expect(json_response[:frame][:total_circles]).to eq(3)
      expect(json_response[:frame][:highest_circle][:id]).to eq(circle_high.id.to_s)
      expect(json_response[:frame][:lowest_circle][:id]).to eq(circle_low.id.to_s)
      expect(json_response[:frame][:leftmost_circle][:id]).to eq(circle_left.id.to_s)
    end

    it "successfully retrieves a frame without circles" do
      frame = create(:frame)

      get :show, params: { id: frame.id }

      expect(response).to have_http_status(:ok)
      expect(json_response[:frame]).to include(x: "0.0", y: "0.0", width: "10.0", height: "10.0")
    end

    it "non-existent frame" do
      get :show, params: { id: "non-existent" }

      expect(response).to have_http_status(:not_found)
      expect(json_response[:error]).to eq("Frame not found")
    end
  end

  context "DELETE #destroy" do
    it "successfully deletes a frame without circles" do
      frame = create(:frame)

      delete :destroy, params: { id: frame.id }

      expect(response).to have_http_status(:no_content)
      expect(Frame.find_by(id: frame.id)).to be_nil
    end

    it "do not delete a frame with circles" do
      frame_with_circles = create(:frame, :with_circles)

      delete :destroy, params: { id: frame_with_circles.id }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response[:error]).to eq("Cannot delete frame with associated circles")
    end

    it "non-existent frame" do
      delete :destroy, params: { id: "non-existent" }

      expect(response).to have_http_status(:not_found)
      expect(json_response[:error]).to eq("Frame not found")
    end
  end
end
