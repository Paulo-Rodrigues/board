# Board

Board is a system for managing frames and associated circles, obeying specific geometric constraints and spacial limits.

The dimensions are defined in centimeters (cm) as decimals.

## Overview

Board consists of:

- **Frames**: Rectangular areas defined by center position (x, y), width, and height
- **Circles**: Circular elements defined by center position (x, y) and diameter
- All measurements are in centimeters with decimal precision

## Business Rules

### Frame Constraints

- Frames cannot touch or overlap other frames
- Frame borders must maintain minimum separation

### Circle Constraints

- Circles must fit completely within their parent frame
- Circles cannot touch or overlap other circles within the same frame
- Each circle must belong to an existing frame

## API Endpoints

### Frames

- `POST /frames` - Create a new frame (with optional nested circles)
- `GET /frames/:id` - Get frame details with circle metrics
- `DELETE /frames/:id` - Delete frame (only if no circles attached)

### Circles

- `POST /frames/:frame_id/circles` - Add circle to specific frame
- `PUT /circles/:id` - Update circle position and diameter
- `GET /circles?center_x=X&center_y=Y&radius=R&frame_id=ID` - Search circles within radius
- `DELETE /circles/:id` - Remove a circle

## Technical Stack

- Ruby on Rails 8 (API-only mode)
- PostgreSQL database
- Docker & Docker Compose
- RSpec for testing
- Swagger/OpenAPI documentation with rswag

## Prerequisites

- Docker
- Docker Compose

## Quick Start

### Development Environment

Clone the repository and navigate into it, then run:

```bash
docker compose build
docker compose up
```

### Accessing the Application

- API: [localhost](http://localhost:3000)
- API Documentation: [localhost/api-docs](http://localhost:3000/api-docs)

If you need to run commands inside the container, use:

```bash
docker exec -it board_api bash
```

### Running Tests

Run all tests with:

```bash
docker exec board_api rspec
```

To run a specific test file:

```bash
docker exec board_api rspec path/to/your_spec.rb
```

### API Documentation

The api documentation is available at `/api-docs` endpoint, generated using Swagger/OpenAPI.

The documentation includes:

- Complete API reference
- Request and response schemas
- Error codes and messages

## API Usage Examples

### Create Frame with Circles

```bash
curl -X POST http://localhost:3000/frames \
  -H "Content-Type: application/json" \
  -d '{
    "frame": {
      "x": 5.0,
      "y": 5.0,
      "width": 10.0,
      "height": 10.0,
      "circles_attributes": [
        {"x": 2.0, "y": 2.0, "diameter": 2.0}
      ]
    }
  }'
```

Search Circles

```bash
curl "http://localhost:3000/circles?center_x=0&center_y=0&radius=5&frame_id=1"
```

