require "swagger_helper"

RSpec.describe "Circles API", type: :request do
  path "/circles/{id}" do
    put "Updates a circle" do
      consumes "application/json"
      produces "application/json"

      parameter name: :id, in: :path, type: :string, description: "ID of the circle"
      parameter name: :circle, in: :body, schema: {
        type: :object,
        properties: {
          circle: {
            type: :object,
            properties: {
              x: { type: :string },
              y: { type: :string },
              diameter: { type: :string }
            }
          }
        }
      }

      response "200", "circle updated" do
        schema type: :object,
          properties: {
            circle: {
              type: :object,
              properties: {
                id: { type: :integer },
                x: { type: :string },
                y: { type: :string },
                diameter: { type: :string }
              },
              required: [ "id", "diameter" ]
            }
          },
          required: [ "circle" ]

        let!(:circle_record) { create(:circle) }
        let(:id) { circle_record.id }
        let(:circle) { { circle: { diameter: (circle_record.diameter + 2).to_s } } }

        run_test! do |response|
          expect(response).to have_http_status(:ok)
          expect(json_response[:circle][:id]).to eq(circle_record.id)
          expect(json_response[:circle][:diameter]).to eq((circle_record.diameter + 2).to_s)
        end
      end

      response "404", "circle not found" do
        schema type: :object,
          properties: {
            error: { type: :string }
          },
          required: [ "error" ]

        let(:id) { "non-existent" }
        let(:circle) { { circle: { diameter: 10 } } }

        run_test! do |response|
          expect(response).to have_http_status(:not_found)
          expect(json_response[:error]).to eq("Circle not found")
        end
      end

      response "422", "unprocessable entity" do
        schema type: :object,
          properties: {
            errors: {
              type: :array,
              items: { type: :string }
            }
          },
          required: [ "errors" ]

        let!(:circle_record) { create(:circle) }
        let(:id) { circle_record.id }
        let(:circle) { { circle: { diameter: nil } } }

        run_test! do |response|
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response[:errors]).to include(a_string_matching(/Diameter|can"t be blank/i))
        end
      end
    end
  end

  path "/circles/{id}" do
    delete "Deletes a circle" do
      consumes "application/json"
      produces "application/json"
      parameter name: :id, in: :path, type: :string, description: "ID of the circle"

      response "204", "circle deleted" do
        let!(:circle) { create(:circle) }
        let(:id) { circle.id }

        run_test! do |response|
          expect(response).to have_http_status(:no_content)
          expect(Circle.exists?(circle.id)).to be false
        end
      end

      response "404", "circle not found" do
        schema type: :object,
          properties: {
            error: { type: :string }
          },
          required: [ "error" ]

        let(:id) { "non-existent" }

        run_test! do |response|
          expect(response).to have_http_status(:not_found)
          expect(json_response[:error]).to eq("Circle not found")
        end
      end
    end
  end
end
