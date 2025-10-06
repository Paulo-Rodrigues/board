require "rails_helper"

describe Frames::CirclesController, type: :controller do
  context "POST #create" do
    let(:frame) { create(:frame) }

    it "successfully creates a circle within a frame" do
      post :create, params: { frame_id: frame.id, circle: { x: 2, y: 2, diameter: 2 } }

      expect(response).to have_http_status(:created)
      expect(json_response[:frame]).to include(id: frame.id)
    end

    it "cannot create a circle with invalid parameters" do
      post :create, params: { frame_id: frame.id, circle: { x: -1, diameter: 2 } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response[:errors]).to include("Y can't be blank")
    end

    it "cannot create a circle outside the frame boundaries" do
      post :create, params: { frame_id: frame.id, circle: { x: 6, y: 0, diameter: 2 } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response[:errors]).to include("Circle exceeds frame boundaries")
    end

    it "cannot create a circle that overlaps with an existing circle" do
      frame = create(:frame, :with_circles)

      post :create, params: { frame_id: frame.id, circle: { x: 2, y: 2, diameter: 2 } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response[:errors]).to include("Circle touches another circle or overlap")
    end
  end
end
