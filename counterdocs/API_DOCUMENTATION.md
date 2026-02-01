# Neelo Sewa API Documentation

## Base URL
```
Production: http://147.93.152.80:5000/api
Development: http://localhost:5000/api
```

## Authentication

### JWT Token
Most endpoints require authentication via JWT token in the Authorization header:
```
Authorization: Bearer <token>
```

### User Types
- **User**: Regular passengers
- **BusOwner**: Bus owners/operators
- **BusAgent**: Ticket counters/agents
- **Driver**: Bus drivers (OTP-based authentication)
- **Admin**: Platform administrators

---

## API Endpoints

### 1. Driver Management

#### 1.1 Invite Driver
**POST** `/api/driver/invite`

**Access**: Owner, Counter, Admin

**Request Body**:
```json
{
  "phoneNumber": "+9779812345678",
  "name": "John Doe",
  "licenseNumber": "DL123456",
  "email": "driver@example.com", // optional
  "busId": "507f1f77bcf86cd799439011" // optional
}
```

**Response**:
```json
{
  "success": true,
  "message": "Driver invitation sent successfully",
  "data": {
    "driverId": "507f1f77bcf86cd799439012",
    "phoneNumber": "+9779812345678",
    "otpExpiresAt": "2024-01-01T12:10:00.000Z"
  }
}
```

#### 1.2 Verify OTP
**POST** `/api/driver/verify-otp`

**Access**: Public

**Request Body**:
```json
{
  "phoneNumber": "+9779812345678",
  "otp": "123456"
}
```

**Response**:
```json
{
  "success": true,
  "message": "OTP verified successfully",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "driver": {
      "id": "507f1f77bcf86cd799439012",
      "name": "John Doe",
      "phoneNumber": "+9779812345678",
      "assignedBusIds": ["507f1f77bcf86cd799439011"]
    }
  }
}
```

#### 1.3 Get Driver Profile
**GET** `/api/driver/profile`

**Access**: Driver

**Response**:
```json
{
  "success": true,
  "data": {
    "_id": "507f1f77bcf86cd799439012",
    "name": "John Doe",
    "phoneNumber": "+9779812345678",
    "licenseNumber": "DL123456",
    "assignedBusId": {...},
    "assignedBusIds": [...],
    "isLocationSharing": true,
    "lastLocation": {
      "latitude": 27.7172,
      "longitude": 85.3240,
      "timestamp": "2024-01-01T12:00:00.000Z"
    }
  }
}
```

#### 1.4 Update Driver Profile
**PUT** `/api/driver/profile`

**Access**: Driver

**Request Body**:
```json
{
  "name": "John Doe Updated",
  "email": "newemail@example.com"
}
```

#### 1.5 Get Assigned Buses
**GET** `/api/driver/assigned-buses`

**Access**: Driver

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "name": "Express Bus",
      "vehicleNumber": "BA-1234",
      "from": "Kathmandu",
      "to": "Pokhara",
      "date": "2024-01-15",
      "time": "07:00",
      "arrival": "12:00",
      "price": 800,
      "totalSeats": 40,
      "busType": "AC"
    }
  ]
}
```

#### 1.6 Start Location Sharing
**POST** `/api/driver/location/start`

**Access**: Driver

**Request Body**:
```json
{
  "busId": "507f1f77bcf86cd799439011"
}
```

#### 1.7 Stop Location Sharing
**POST** `/api/driver/location/stop`

**Access**: Driver

#### 1.8 Get Trip Status
**GET** `/api/driver/trip-status?busId=507f1f77bcf86cd799439011`

**Access**: Driver

**Response**:
```json
{
  "success": true,
  "data": {
    "bus": {
      "id": "507f1f77bcf86cd799439011",
      "name": "Express Bus",
      "vehicleNumber": "BA-1234",
      "route": "Kathmandu to Pokhara",
      "date": "2024-01-15",
      "time": "07:00"
    },
    "passengerCount": 25,
    "totalSeats": 40,
    "availableSeats": 15,
    "isLocationSharing": true
  }
}
```

---

### 2. Location Tracking

#### 2.1 Update Location
**POST** `/api/location/update`

**Access**: Driver

**Request Body**:
```json
{
  "busId": "507f1f77bcf86cd799439011",
  "latitude": 27.7172,
  "longitude": 85.3240,
  "speed": 60, // optional, in km/h
  "heading": 90, // optional, in degrees
  "accuracy": 10 // optional, in meters
}
```

**Response**:
```json
{
  "success": true,
  "message": "Location updated successfully",
  "data": {
    "locationId": "507f1f77bcf86cd799439013",
    "timestamp": "2024-01-01T12:00:00.000Z"
  }
}
```

#### 2.2 Get Current Location
**GET** `/api/location/bus/:busId/current`

**Access**: Public

**Response**:
```json
{
  "success": true,
  "data": {
    "busId": "507f1f77bcf86cd799439011",
    "latitude": 27.7172,
    "longitude": 85.3240,
    "speed": 60,
    "heading": 90,
    "accuracy": 10,
    "timestamp": "2024-01-01T12:00:00.000Z",
    "driver": {
      "_id": "507f1f77bcf86cd799439012",
      "name": "John Doe",
      "phoneNumber": "+9779812345678"
    }
  }
}
```

#### 2.3 Get Location History
**GET** `/api/location/bus/:busId/history?startTime=2024-01-01T00:00:00Z&endTime=2024-01-01T23:59:59Z&limit=100`

**Access**: Public

**Query Parameters**:
- `startTime` (optional): ISO 8601 date string
- `endTime` (optional): ISO 8601 date string
- `limit` (optional): Number of records (default: 100)

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "latitude": 27.7172,
      "longitude": 85.3240,
      "speed": 60,
      "heading": 90,
      "timestamp": "2024-01-01T12:00:00.000Z"
    }
  ]
}
```

#### 2.4 Get Location by Ticket
**GET** `/api/location/ticket/:ticketNumber`

**Access**: Public

**Response**:
```json
{
  "success": true,
  "data": {
    "ticketNumber": "bus-20240101-123456",
    "bus": {
      "id": "507f1f77bcf86cd799439011",
      "name": "Express Bus",
      "from": "Kathmandu",
      "to": "Pokhara"
    },
    "location": {
      "latitude": 27.7172,
      "longitude": 85.3240,
      "speed": 60,
      "heading": 90,
      "timestamp": "2024-01-01T12:00:00.000Z"
    },
    "driver": {...}
  }
}
```

---

### 3. Seat Locking

#### 3.1 Lock Seat
**POST** `/api/seat-lock/lock`

**Access**: User, Counter

**Request Body**:
```json
{
  "busId": "507f1f77bcf86cd799439011",
  "seatNumber": 5
}
```

**Response**:
```json
{
  "success": true,
  "message": "Seat locked successfully",
  "data": {
    "lockId": "507f1f77bcf86cd799439014",
    "busId": "507f1f77bcf86cd799439011",
    "seatNumber": 5,
    "expiresAt": "2024-01-01T12:10:00.000Z"
  }
}
```

#### 3.2 Unlock Seat
**POST** `/api/seat-lock/unlock`

**Access**: User, Counter

**Request Body**:
```json
{
  "busId": "507f1f77bcf86cd799439011",
  "seatNumber": 5
}
```

#### 3.3 Lock Multiple Seats
**POST** `/api/seat-lock/lock-multiple`

**Access**: User, Counter

**Request Body**:
```json
{
  "busId": "507f1f77bcf86cd799439011",
  "seatNumbers": [5, 6, 7]
}
```

**Response**:
```json
{
  "success": true,
  "message": "Seats locked successfully",
  "data": {
    "locks": [
      {"lockId": "...", "seatNumber": 5},
      {"lockId": "...", "seatNumber": 6},
      {"lockId": "...", "seatNumber": 7}
    ],
    "expiresAt": "2024-01-01T12:10:00.000Z"
  }
}
```

#### 3.4 Get Bus Locks
**GET** `/api/seat-lock/bus/:busId`

**Access**: Public

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "seatNumber": 5,
      "lockedBy": "507f1f77bcf86cd799439015",
      "lockedByType": "User",
      "expiresAt": "2024-01-01T12:10:00.000Z"
    }
  ]
}
```

#### 3.5 Get My Locks
**GET** `/api/seat-lock/my-locks`

**Access**: User, Counter

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "busId": {
        "_id": "507f1f77bcf86cd799439011",
        "name": "Express Bus",
        "from": "Kathmandu",
        "to": "Pokhara",
        "date": "2024-01-15",
        "time": "07:00"
      },
      "seatNumber": 5,
      "expiresAt": "2024-01-01T12:10:00.000Z"
    }
  ]
}
```

---

### 4. Schedule Management

#### 4.1 Create Schedule
**POST** `/api/schedules`

**Access**: Owner, Admin

**Request Body**:
```json
{
  "busId": "507f1f77bcf86cd799439011",
  "route": {
    "from": "Kathmandu",
    "to": "Pokhara"
  },
  "daysOfWeek": [1, 2, 3, 4, 5], // 0=Sunday, 6=Saturday
  "departureTime": "07:00",
  "arrivalTime": "12:00",
  "startDate": "2024-01-01",
  "endDate": "2024-12-31" // optional, null for no end date
}
```

**Response**:
```json
{
  "success": true,
  "message": "Schedule created successfully",
  "data": {
    "_id": "507f1f77bcf86cd799439016",
    "busId": "507f1f77bcf86cd799439011",
    "route": {...},
    "daysOfWeek": [1, 2, 3, 4, 5],
    "departureTime": "07:00",
    "arrivalTime": "12:00",
    "isActive": true,
    "startDate": "2024-01-01T00:00:00.000Z",
    "endDate": "2024-12-31T00:00:00.000Z"
  }
}
```

#### 4.2 Get Schedules
**GET** `/api/schedules?busId=507f1f77bcf86cd799439011&isActive=true`

**Access**: Owner, Admin

**Query Parameters**:
- `busId` (optional): Filter by bus ID
- `isActive` (optional): Filter by active status

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "_id": "507f1f77bcf86cd799439016",
      "busId": {...},
      "route": {...},
      "daysOfWeek": [1, 2, 3, 4, 5],
      "departureTime": "07:00",
      "arrivalTime": "12:00",
      "isActive": true
    }
  ]
}
```

#### 4.3 Get Schedule by ID
**GET** `/api/schedules/:id`

**Access**: Owner, Admin

#### 4.4 Update Schedule
**PUT** `/api/schedules/:id`

**Access**: Owner, Admin

**Request Body**:
```json
{
  "route": {...}, // optional
  "daysOfWeek": [1, 2, 3, 4, 5], // optional
  "departureTime": "08:00", // optional
  "arrivalTime": "13:00", // optional
  "startDate": "2024-01-01", // optional
  "endDate": "2024-12-31", // optional
  "isActive": false // optional
}
```

#### 4.5 Delete Schedule
**DELETE** `/api/schedules/:id`

**Access**: Owner, Admin

---

## WebSocket Events (Socket.IO)

### Client → Server Events

#### `bus:location:subscribe`
Subscribe to bus location updates
```javascript
socket.emit('bus:location:subscribe', { busId: '507f1f77bcf86cd799439011' });
```

### Server → Client Events

#### `bus:location:update`
Real-time bus location update
```javascript
socket.on('bus:location:update', (data) => {
  // data: { busId, latitude, longitude, speed, heading, timestamp }
});
```

#### `seat:locked`
Seat lock notification
```javascript
socket.on('seat:locked', (data) => {
  // data: { busId, seatNumber, lockedBy, lockedByType, expiresAt }
});
```

#### `seat:unlocked`
Seat unlock notification
```javascript
socket.on('seat:unlocked', (data) => {
  // data: { busId, seatNumber }
});
```

#### `seats:locked`
Multiple seats locked notification
```javascript
socket.on('seats:locked', (data) => {
  // data: { busId, seatNumbers, lockedBy, lockedByType, expiresAt }
});
```

---

## Error Responses

All error responses follow this format:

```json
{
  "success": false,
  "message": "Error message describing what went wrong",
  "error": "Detailed error message (development only)"
}
```

### Common HTTP Status Codes

- `200` - Success
- `201` - Created
- `400` - Bad Request (validation errors, missing parameters)
- `401` - Unauthorized (invalid or missing token)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found
- `500` - Internal Server Error

---

## Rate Limiting

API requests are rate-limited:
- **Development**: 10,000 requests per 15 minutes
- **Production**: 100 requests per 15 minutes

Rate limit headers are included in responses:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1609459200
```

---

## Notes

1. All timestamps are in ISO 8601 format (UTC)
2. All coordinates use WGS84 (latitude/longitude)
3. Seat numbers are 1-indexed
4. OTP expires after 10 minutes
5. Seat locks expire after 10 minutes
6. Location history is kept for 7 days (auto-deleted after)
7. All monetary values are in Nepalese Rupees (NPR)

---

## Support

For API support, contact: support@neelosewa.com


