# Package Delivery Backend

A Rails API-only backend for a package delivery platform. It handles user and driver registration, delivery request creation, nearest driver assignment, delivery lifecycle management, and event tracking.

---

## Requirements

- Ruby 3.4.7
- Rails 7.2
- PostgreSQL
- Bundler

---

## Setup

**1. Clone the repository**
```bash
git clone https://github.com/abrakingoo/package_delivery_backend_system.git
cd package_delivery_backend_system
```

**2. Install dependencies**
```bash
bundle install
```

**3. Configure environment**

Copy and update database credentials:
```bash
cp config/database.yml.example config/database.yml
```

**4. Create and migrate the database**
```bash
rails db:create db:migrate
```

**5. Seed drivers**
```bash
rails db:seed
```
This creates 10 available drivers positioned around Nairobi, Kenya.

**6. Start the server**
```bash
rails server
```

The API will be available at `http://localhost:3000`.

---

## Running Tests

```bash
rails test
```

Tests are organized into:
- `test/models/` — model validation specs
- `test/integration/` — request specs for all endpoints
- `test/services/` — unit specs for business logic services

---

## API Endpoints

All protected endpoints require token sent in the header:
```
Authorization: Bearer <token>
```

### Authentication

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/auth/register` | Register a user or driver | No |
| POST | `/auth/login` | Login and receive a JWT token | No |

**Register a user**
```json
POST /auth/register
{
  "user": {
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "role": "client"
  }
}
```

**Register a driver**
```json
POST /auth/register
{
  "user": {
    "name": "James Mwangi",
    "email": "james@driver.com",
    "phone": "0712345601",
    "available": true,
    "password": "password123",
    "password_confirmation": "password123",
    "role": "driver"
  }
}
```

**Login**
```json
POST /auth/login
{
  "user": {
    "email": "john@example.com",
    "password": "password123"
  }
}
```

---

### Deliveries (User)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/delivery_request` | Create a new delivery request | User |
| GET | `/deliveries` | List all deliveries for current user | User |
| GET | `/deliveries/:id` | Get a single delivery with status | User |
| GET | `/deliveries/:id/events` | Get delivery event history | User/Driver |

**Create a delivery request**
```json
POST /delivery_request
Idempotency-Key: <unique-key>

{
  "delivery_request": {
    "description": "Laptop",
    "weight": 2.5,
    "pick_up_address": {
      "street": "Kenyatta Avenue",
      "city": "Nairobi",
      "country": "Kenya"
    },
    "delivery_address": {
      "street": "Moi Avenue",
      "city": "Nairobi",
      "country": "Kenya"
    }
  }
}
```

---

### Driver

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| PATCH | `/driver/location` | Update driver's current location | Driver |
| PATCH | `/driver/requests/:id/respond` | Accept or reject a delivery request | Driver |
| PATCH | `/deliveries/:id/status` | Advance delivery status | Driver |

**Update driver location**
```json
PATCH /driver/location
{
  "location": {
    "latitude": -1.2921,
    "longitude": 36.8219
  }
}
```

**Respond to a delivery request**
```json
PATCH /driver/requests/:id/respond
{
  "response_action": "accept"
}
```

**Update delivery status**
```json
PATCH /deliveries/:id/status
{
  "status": "picked_up"
}
```

---

### Delivery Lifecycle

Status transitions follow a strict order:

```
pending → assigned → accepted → picked_up → in_transit → delivered
```

Any attempt to skip a step will return a `422 Unprocessable Entity`.

---

## Architecture Overview

The application follows a service object pattern — controllers are kept thin and delegate all business logic to service objects.

```
app/
├── controllers/        # Thin controllers, handle HTTP in/out only
├── jobs/
│   └── GeocodeAndAssignDriverJob     # Async geocoding and driver assignment
├── services/           # Business logic
│   ├── AuthenticationService         # JWT login
│   ├── RegistrationService           # User/Driver registration
│   ├── DeliveryRequestService        # Create delivery + enqueue background job
│   ├── NearestDriverAssignmentService # Find and notify nearby drivers
│   ├── DriverRequestResponseService  # Accept/reject driver requests
│   ├── DeliveryStatusUpdateService   # Enforce lifecycle transitions
│   ├── DriverLocationService         # Update driver GPS
│   ├── GeocodingService              # Geocode addresses via Nominatim
│   └── JwtService                    # Encode/decode JWT tokens
└── models/
    ├── User                  # Client/customer
    ├── Driver                # Delivery driver
    ├── DeliveryRequest       # Core delivery record with lifecycle status
    ├── Address               # Pickup and delivery coordinates
    ├── DriverRequest         # Pending assignment sent to a driver
    ├── DriverLocation        # Driver's current GPS position
    └── DeliveryEvent         # Audit log of status changes
```

**Key flows:**

1. User creates delivery → `DeliveryRequestService` persists the record and immediately returns it → `GeocodeAndAssignDriverJob` runs in the background to geocode addresses and find nearby drivers
2. Driver accepts via `DriverRequestResponseService` → delivery marked `assigned`, other pending requests deleted, driver marked unavailable
3. Driver advances status via `DeliveryStatusUpdateService` → transition validated, `DeliveryEvent` logged, driver marked available on delivery

---

## Assumptions

- **Background jobs** — geocoding and driver assignment run asynchronously via `GeocodeAndAssignDriverJob`. Rails uses the async adapter by default (in-process threads). In production, swap to Sidekiq or GoodJob with Redis for reliability.
- **No push notifications** — in production, drivers would be notified via push/websocket when a `DriverRequest` is created. Currently simulated by polling or direct API calls.
- **Single driver per delivery** — the first driver to accept wins; all other pending requests are deleted.
- **Geocoding via Nominatim** — the free OpenStreetMap geocoder is used. In production, consider Google Maps or a paid provider for reliability.
- **JWT authentication** — tokens expire after 24 hours. No refresh token mechanism is implemented.
- **Idempotency keys** — required on delivery creation to prevent duplicate requests from retries.
- **Driver availability** — automatically set to `false` on acceptance and back to `true` on delivery completion.
- **No admin role** — there is no admin interface or admin-specific endpoints at this stage.
- **Status transitions are linear** — no support for cancellations or reversals in the current implementation.
