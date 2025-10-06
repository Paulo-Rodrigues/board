require "swagger_helper"

RSpec.describe "Frames::Circles", type: :request do
  path "/frames/{frame_id}/circles" do
    post "Creates a circle within a frame" do
      consumes "application/json"
      produces "application/json"

      parameter name: :frame_id, in: :path, type: :integer, description: "ID of the parent frame"
      parameter name: :circle, in: :body, schema: {
        type: :object,
        properties: {
          circle: {
            type: :object,
            properties: {
              x: { type: :number },
              y: { type: :number },
              diameter: { type: :number }
            },
            required: [ "x", "y", 'diameter' ]
          }
        },
        required: [ "circle" ]
      }

      response "201", "circle created" do
        schema type: :object,
          properties: {
            frame: {
              type: :object,
              properties: {
                id: { type: :integer },
                x: { type: :string },
                y: { type: :string },
                width: { type: :string },
                height: { type: :string },
                circles: {
                  type: :array,
                  items: {
                    type: :object,
                    properties: {
                      id: { type: :integer },
                      x: { type: :string },
                      y: { type: :string },
                      diameter: { type: :string }
                    },
                    required: [ "id", "x", 'y', 'diameter' ]
                  }
                }
              },
              required: [ "id" ]
            }
          },
          required: [ "frame" ]

        let(:frame) { create(:frame) }
        let(:frame_id) { frame.id }
        let(:circle) { { circle: { x: 2, y: 2, diameter: 2 } } }

        run_test! do |response|
          expect(response).to have_http_status(:created)
          expect(json_response).to include(:frame)
          expect(json_response[:frame][:id]).to eq(frame.id)
          expect(json_response[:frame][:circles]).to be_an(Array)
        end
      end

      response "422", "invalid parameters" do
        schema type: :object,
          properties: {
            errors: {
              type: :array,
              items: { type: :string }
            }
          },
          required: [ "errors" ]

        let(:frame) { create(:frame) }
        let(:frame_id) { frame.id }
        let(:circle) { { circle: { x: -1, diameter: 2 } } }

        run_test! do |response|
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response).to include(:errors)
          expect(json_response[:errors]).to be_an(Array)
        end
      end

      response "422", "circle exceeds frame boundaries" do
        schema type: :object,
          properties: {
            errors: {
              type: :array,
              items: { type: :string }
            }
          },
          required: [ "errors" ]

        let(:frame) { create(:frame, x: 0.0, y: 0.0, width: 10.0, height: 10.0) }
        let(:frame_id) { frame.id }
        let(:circle) { { circle: { x: 6, y: 0, diameter: 2 } } }

        run_test! do |response|
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response).to include(:errors)
          expect(json_response[:errors]).to include(a_string_matching(/Circle exceeds frame boundaries/))
        end
      end

      response "422", "circle overlaps existing circle" do
        schema type: :object,
          properties: {
            errors: {
              type: :array,
              items: { type: :string }
            }
          },
          required: [ "errors" ]

        let(:frame) { create(:frame) }
        let(:frame_id) { frame.id }
        let!(:existing_circle) { create(:circle, frame: frame, x: 2.0, y: 2.0, diameter: 2.0) }
        let(:circle) { { circle: { x: 2.0, y: 2.0, diameter: 2.0 } } }

        run_test! do |response|
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response).to include(:errors)
          expect(json_response[:errors]).to include(a_string_matching(/Circle touches another circle|overlap/i))
        end
      end

      response "404", "frame not found" do
        let(:frame_id) { 999_999 }
        let(:circle) { { circle: { x: 2, y: 2, diameter: 2 } } }

        run_test! do |response|
          expect(response).to have_http_status(:not_found)
          expect(json_response).to include(:error)
        end
      end
    end
  end
end
