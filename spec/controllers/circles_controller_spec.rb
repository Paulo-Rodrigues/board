require "rails_helper"

describe CirclesController, type: :controller do
  context "GET /index" do
    let!(:frame) { create(:frame) }
    let!(:other_frame) { create(:frame, x: 30.0, y: 30.0) }
    let!(:circle_inside) { create(:circle, x: 1.0, y: 1.0, diameter: 2.0, frame: frame) }
    let!(:circle_outside) { create(:circle, x: 4.5, y: 4.5, diameter: 1.0, frame: frame) }
    let!(:circle_in_other_frame) { create(:circle, x: 30.0, y: 30.0, diameter: 2.0, frame: other_frame) }

    it "returns circles within the specified frame" do
      get :index, params: { frame_id: frame.id, center_x: 0, center_y: 0, radius: 5 }


      expect(response).to have_http_status(:ok)
      expect(json_response[:circles].size).to eq(1)
      expect(json_response[:circles].first[:id]).to eq(circle_inside.id)
    end

    it "does not return circles from other frames" do
      get :index, params: { frame_id: frame.id, center_x: 0, center_y: 0, radius: 5 }

      inside_ids = json_response[:circles].map { |c| c[:id] }

      expect(inside_ids).not_to include(circle_in_other_frame.id)
      expect(inside_ids).to include(circle_inside.id)
    end
  end

  context "PUT #update" do
    it "successfully updates a circle" do
      circle = create(:circle)

      put :update, params: { id: circle.id, circle: { diameter: circle.diameter + 2 } }

      expect(response).to have_http_status(:ok)
      expect(json_response[:circle][:diameter]).to eq((circle.diameter + 2).to_s)
    end

    it "returns 404 if circle not found" do
      put :update, params: { id: 'non-existent', circle: { diameter: 10 } }

      expect(response).to have_http_status(:not_found)
      expect(json_response[:error]).to eq('Circle not found')
    end

    it "returns 422 if update fails" do
      circle1 = create(:circle)

      put :update, params: { id: circle1.id, circle: { diameter: nil } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response[:errors]).to include("Diameter can't be blank")
    end
  end

  context "DELETE #destroy" do
    it "successfully deletes a circle" do
      circle = create(:circle)

      delete :destroy, params: { id: circle.id }

      expect(response).to have_http_status(:no_content)
      expect(Circle.exists?(circle.id)).to be_falsey
    end

    it "returns 404 if circle not found" do
      delete :destroy, params: { id: 'non-existent' }

      expect(response).to have_http_status(:not_found)
      expect(json_response[:error]).to eq('Circle not found')
    end
  end
end
