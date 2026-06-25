# Package Delivery Backend

A Rails API-only backend for a package delivery platform. It handles user and driver registration, delivery request creation, nearest driver assignment, delivery lifecycle management, and event tracking.

---

## Requirements

- Ruby 3.4.7
- Rails 7.2
- PostgreSQL
- Bundler

---

## Quick Start (Docker)

The fastest way to run the app — only requires Docker.

**1. Clone the repository**
```bash
git clone https://github.com/abrakingoo/package_delivery_backend_system.git
cd package_delivery_backend_system
```

**2. Set your Rails master key**
```bash
export RAILS_MASTER_KEY=$(cat config/master.key)
```

**3. Start the app**
```bash
docker compose up --build
```

This will:
- Start a PostgreSQL database
- Run migrations and seed 10 drivers around Nairobi
- Start the Rails server on `http://localhost:3000`

**4. Test it**
```bash
curl http://localhost:3000/up
```

> Use [Postman](https://www.postman.com) or curl to interact with the API. See [API Endpoints](#api-endpoints) below.

---

## Manual Setup

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

If you're using a local PostgreSQL installation that requires authentication, uncomment and update the `username`, `password`, `host`, and `port` fields in `config/database.yml`.

For default PostgreSQL setups (like Homebrew on macOS or pg_hba.conf trust mode on Linux), the defaults work without changes.

> **JWT Secret:** The JWT token secret is automatically derived from `Rails.application.secret_key_base` (stored in `config/credentials.yml.enc`). Rails generates this automatically on setup — no manual configuration needed.

**4. Create and migrate the database**
```bash
rails db:create db:migrate
```

**5. Seed drivers**
```bash
rails db:seed
```
This creates 10 available drivers positioned around Nairobi, Kenya.

> All seeded drivers use the password `password123`. You can log in as any of them using their email (e.g. `james@driver.com`).

**6. Start the server**
```bash
rails server
```

The API will be available at `http://localhost:3000`.

> This is an API-only application — there is no browser interface. Use a REST client to interact with the endpoints:
> - [Postman](https://www.postman.com)
> - [Insomnia](https://insomnia.rest)
> - [curl](https://curl.se)

---

## Quick Start: End-to-End Example

Here's a complete flow using curl to test the system in under 5 minutes:

**1. Register a user**
```bash
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "name": "John Doe",
      "email": "john@example.com",
      "password": "password123",
      "password_confirmation": "password123",
      "role": "client"
    }
  }'
```

**2. Login and save the token**
```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "john@example.com",
      "password": "password123"
    }
  }'
# Copy the token from the response
```

**3. Create a delivery request**
```bash
curl -X POST http://localhost:3000/delivery_request \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Idempotency-Key: $(uuidgen)" \
  -d '{
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
  }'
# Note the delivery_request id from the response
```

**4. Check delivery status**
```bash
curl -X GET http://localhost:3000/deliveries/1 \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

**5. Login as a driver and accept the delivery**
```bash
# Login as seeded driver
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "james@driver.com",
      "password": "password123"
    }
  }'
# Copy the driver token

# Accept the driver request (use the driver_request id from step 3 response)
curl -X PATCH http://localhost:3000/driver/requests/1/respond \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer DRIVER_TOKEN_HERE" \
  -d '{"response_action": "accept"}'

# Update delivery status
curl -X PATCH http://localhost:3000/deliveries/1/status \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer DRIVER_TOKEN_HERE" \
  -d '{"status": "picked_up"}'
```

**✓ You've tested the core flow.** See the full API reference below for all endpoints, or jump to [Delivery Lifecycle](#delivery-lifecycle) to understand status transitions.

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

### Rate Limiting

The following limits are enforced per IP via `rack-attack`. Exceeding them returns `429 Too Many Requests`.

| Endpoint | Limit |
|----------|-------|
| `POST /auth/login` | 5 requests / minute (also by email) |
| `POST /auth/register` | 10 requests / hour |
| `POST /delivery_request` | 10 requests / minute |
| `PATCH /driver/location` | 60 requests / minute |

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

> **Note:** The `Idempotency-Key` header is required to prevent duplicate deliveries from retries. Use a UUID (e.g. `uuidgen` on macOS/Linux or any UUID generator).

> **Note:** This endpoint geocodes addresses using Nominatim in real-time, which may take 2-5 seconds. If the request appears to hang, the geocoding service may be slow or unavailable.

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
requested → assigned → accepted → picked_up → in_transit → delivered
```

Any attempt to skip a step will return a `422 Unprocessable Entity`.

---

## Architecture Overview

The application follows a service object pattern — controllers are kept thin and delegate all business logic to service objects.

```
app/
├── controllers/        # Thin controllers, handle HTTP in/out only
├── services/           # Business logic
│   ├── AuthenticationService         # JWT login
│   ├── RegistrationService           # User/Driver registration
│   ├── DeliveryRequestService        # Create delivery, geocode addresses, assign drivers
│   ├── NearestDriverAssignmentService # Find nearby drivers and create DriverRequests
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

1. User creates delivery → `DeliveryRequestService` geocodes addresses, persists the record, finds nearby available drivers via `NearestDriverAssignmentService`, and creates a `DriverRequest` for each
2. Driver accepts via `DriverRequestResponseService` → delivery marked `assigned`, all other pending driver requests rejected, driver marked unavailable
3. Driver advances status via `DeliveryStatusUpdateService` → transition validated, `DeliveryEvent` logged, driver marked available on delivery

---

## Assumptions

- **Geocoding and driver assignment** — run synchronously within the delivery request creation flow. In production, consider moving this to a background job (Sidekiq or GoodJob) to avoid slow response times.
- **No push notifications** — in production, drivers would be notified via push/websocket when a `DriverRequest` is created. Currently simulated by polling or direct API calls.
- **Single driver per delivery** — the first driver to accept wins; all other pending requests are rejected.
- **Geocoding via Nominatim** — the free OpenStreetMap geocoder is used. In production, consider Google Maps or a paid provider for reliability.
- **JWT authentication** — tokens expire after 24 hours. No refresh token mechanism is implemented.
- **Idempotency keys** — required on delivery creation to prevent duplicate requests from retries.
- **Driver availability** — defaults to `true` on registration, set to `false` on delivery acceptance, and back to `true` on delivery completion.
- **Rate limiting** — enforced via `rack-attack` on auth and delivery endpoints. Uses Rails cache store (in-memory). In production, swap to Redis for multi-server support.
- **No admin role** — there is no admin interface or admin-specific endpoints at this stage.
- **Status transitions are linear** — no support for cancellations or reversals in the current implementation.
