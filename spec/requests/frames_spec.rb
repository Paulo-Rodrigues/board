require "swagger_helper"

describe "Frames API", type: :request do
  path "/frames" do
    post "Creates a frame" do
      consumes "application/json"
      parameter name: :frame, in: :body, schema: {
        type: :object,
        properties: {
          x: { type: :number },
          y: { type: :number },
          width: { type: :number },
          height: { type: :number },
          circles_attributes: {
            type: :array,
            items: {
              type: :object,
              properties: {
                x: { type: :number },
                y: { type: :number },
                diameter: { type: :number }
              }
            }
          },
          required: [ "x", "y", "diameter" ]
        },
        required: [ "x", "y", "width", "height" ]
      }

      response "201", "frame created" do
        let(:frame) do
          {
            x: 10.0,
            y: 10.0,
            width: 10.0,
            height: 10.0,
            circles_attributes: [
              { x: 12, y: 12, diameter: 2 },
              { x: 8, y: 8, diameter: 2 }
            ]
          }
        end

        run_test!
      end

      response "422", "invalid request" do
        let(:frame) do
          {
            x: 10.0,
            y: 10.0,
            height: 10.0
          }
        end

        run_test! do |response|
          expect(response.body).to match(/Width can't be blank/)
        end
      end

      response "422", "invalid circle" do
        let(:frame) do
          {
            x: 10.0,
            y: 10.0,
            width: 10.0,
            height: 10.0,
            circles_attributes: [
              { x: 12, y: 12 }
            ]
          }
        end

        run_test! do |response|
          expect(response.body).to include("diameter can't be blank")
        end
      end
    end
  end

  path "/frames/{id}" do
    get "Retrieves a frame" do
      produces "application/json"
      parameter name: :id, in: :path, type: :string

      response "200", "frame found" do
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
                total_circles: { type: :integer },
                highest_circle: {
                  type: :object,
                  nullable: true,
                  properties: {
                    id: { type: :string },
                    x: { type: :string },
                    y: { type: :string }
                  }
                },
                lowest_circle: {
                  type: :object,
                  nullable: true,
                  properties: {
                    id: { type: :string },
                    x: { type: :string },
                    y: { type: :string }
                  }
                },
                leftmost_circle: {
                  type: :object,
                  nullable: true,
                  properties: {
                    id: { type: :string },
                    x: { type: :string },
                    y: { type: :string }
                  }
                },
                rightmost_circle: {
                  type: :object,
                  nullable: true,
                  properties: {
                    id: { type: :string },
                    x: { type: :string },
                    y: { type: :string }
                  }
                }
              },
              required: [ "id", "x", "y", "width", "height", "total_circles" ]
            }
          },
          required: [ "frame" ]

        let(:id) { Frame.create(x: 10, y: 10, width: 10, height: 10).id }
        run_test!
      end

      response "404", "frame not found" do
        let(:id) { "non-existent" }
        run_test! do |response|
          expect(response.body).to match(/Frame not found/)
        end
      end
    end
  end

  path "/frames/{id}" do
    delete "Deletes a frame" do
      consumes "application/json"
      parameter name: :id, in: :path, type: :string

      response "204", "frame deleted" do
        let(:frame) { Frame.create(x: 10, y: 10, width: 10, height: 10) }
        let(:id) { frame.id }

        run_test! do |response|
          expect(response.body).to be_empty
          expect(Frame.find_by(id: id)).to be_nil
        end
      end

      response "422", "cannot delete frame with circles" do
        let(:frame) do
          Frame.create(
            x: 10, y: 10, width: 10, height: 10,
            circles: [ Circle.new(x: 12, y: 12, diameter: 2) ]
          )
        end
        let(:id) { frame.id }

        run_test! do |response|
          expect(response.body).to match(/Cannot delete frame with associated circles/)
        end
      end
    end
  end
end
