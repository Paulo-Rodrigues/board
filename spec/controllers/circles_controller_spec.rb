require "rails_helper"

describe CirclesController, type: :controller do
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
