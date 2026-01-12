# Bus Counter / Agent API Documentation

## Overview
This document provides a complete list of all APIs available for the Bus Counter / Agent module. These endpoints enable counters to manage bookings, view assigned buses, handle sales, and operate in offline mode.

**Base URL**: `/api/counter`

**Authentication**: All endpoints require Bearer token authentication (JWT)

---

## Table of Contents
1. [Dashboard & Bus Management](#dashboard--bus-management)
2. [Booking Management](#booking-management)
3. [Sales & Reports](#sales--reports)
4. [Offline Mode](#offline-mode)
5. [Audit Logs](#audit-logs)

---

## Dashboard & Bus Management

### 1. Get Counter Dashboard
**Endpoint**: `GET /api/counter/dashboard`

**Description**: Returns counter dashboard data including assigned buses (grouped by date/route), today's statistics, and wallet balance.

**Request Headers**:
```
Authorization: Bearer <token>
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "counter": {
      "id": "507f1f77bcf86cd799439011",
      "agencyName": "ABC Travels",
      "email": "abc@example.com",
      "walletBalance": 5000.00
    },
    "assignedBuses": {
      "2024-01-15": {
        "Kathmandu-Pokhara": {
          "route": {
            "from": "Kathmandu",
            "to": "Pokhara"
          },
          "buses": [
            {
              "_id": "507f1f77bcf86cd799439012",
              "name": "Deluxe Bus",
              "from": "Kathmandu",
              "to": "Pokhara",
              "date": "2024-01-15",
              "time": "07:00",
              "price": 800,
              "totalSeats": 40,
              "accessId": "507f1f77bcf86cd799439013",
              "allowedSeats": [],
              "commissionEarned": 500,
              "totalBookings": 25
            }
          ]
        }
      }
    },
    "todayStats": {
      "totalBookings": 15,
      "totalSales": 12000,
      "cashSales": 8000,
      "onlineSales": 4000,
      "busesWithBookings": 3
    }
  }
}
```

---

### 2. Get Assigned Buses
**Endpoint**: `GET /api/counter/buses`

**Description**: Get all buses assigned to the counter with real-time seat availability and trip status. Supports filtering.

**Query Parameters**:
- `date` (optional): Filter by bus date (e.g., "2024-01-15")
- `route` (optional): Filter by route (searches in from/to fields)
- `status` (optional): Filter by trip status (Scheduled/Departed/Completed)
- `owner` (optional): Filter by owner email

**Request Headers**:
```
Authorization: Bearer <token>
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "buses": [
      {
        "_id": "507f1f77bcf86cd799439012",
        "name": "Deluxe Bus",
        "from": "Kathmandu",
        "to": "Pokhara",
        "date": "2024-01-15",
        "time": "07:00",
        "arrival": "12:00",
        "price": 800,
        "totalSeats": 40,
        "filledSeats": 25,
        "availableSeats": 15,
        "bookedSeats": [1, 2, 3, 5, 7, 10, 12, 15, 18, 20, 22, 25, 28, 30, 32, 35, 37, 38, 39, 40],
        "lockedSeats": [4, 6],
        "tripStatus": "Scheduled",
        "accessId": "507f1f77bcf86cd799439013",
        "allowedSeats": [],
        "commissionEarned": 500,
        "totalBookings": 25
      }
    ]
  }
}
```

**Trip Status Values**:
- `Scheduled`: Bus has not departed yet
- `Departed`: Bus has departed but not completed
- `Completed`: Bus trip is completed

---

### 3. Get Bus Details
**Endpoint**: `GET /api/counter/buses/:busId`

**Description**: Get detailed information about a specific bus including real-time seat availability, locked seats, and booking status.

**URL Parameters**:
- `busId`: MongoDB ObjectId of the bus

**Request Headers**:
```
Authorization: Bearer <token>
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "bus": {
      "_id": "507f1f77bcf86cd799439012",
      "name": "Deluxe Bus",
      "from": "Kathmandu",
      "to": "Pokhara",
      "date": "2024-01-15",
      "time": "07:00",
      "arrival": "12:00",
      "price": 800,
      "totalSeats": 40,
      "filledSeats": 25,
      "availableSeats": 15,
      "bookedSeats": [1, 2, 3, 5, 7, 10, 12, 15, 18, 20, 22, 25, 28, 30, 32, 35, 37, 38, 39, 40],
      "lockedSeats": [
        {
          "seatNumber": 4,
          "lockedBy": "BusAgent",
          "lockedByUser": {
            "_id": "507f1f77bcf86cd799439014",
            "agencyName": "XYZ Travels"
          },
          "expiresAt": "2024-01-15T07:10:00.000Z"
        }
      ],
      "tripStatus": "Scheduled",
      "allowedSeats": [],
      "commissionEarned": 500,
      "totalBookings": 25
    }
  }
}
```

**Error Response** (403 Forbidden):
```json
{
  "success": false,
  "message": "You do not have access to this bus"
}
```

---

## Booking Management

### 4. Create Booking
**Endpoint**: `POST /api/counter/bookings`

**Description**: Create a new booking with seat locking mechanism. Seats are automatically locked during booking process to prevent double booking.

**Request Headers**:
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Request Body**:
```json
{
  "busId": "507f1f77bcf86cd799439012",
  "seatNumbers": [4, 5, 6],
  "passengerName": "John Doe",
  "contactNumber": "9841234567",
  "passengerEmail": "john@example.com",
  "paymentMethod": "cash"
}
```

**Request Body Fields**:
- `busId` (required): MongoDB ObjectId of the bus
- `seatNumbers` (required): Array of seat numbers to book
- `passengerName` (required): Name of the passenger
- `contactNumber` (required): Contact number of the passenger
- `passengerEmail` (optional): Email of the passenger
- `paymentMethod` (optional): `cash` | `online` | `wallet` (default: `cash`)

**Response** (201 Created):
```json
{
  "success": true,
  "message": "Booking created successfully",
  "data": {
    "booking": {
      "ticketNumber": "bus-20240115-123456",
      "seatNumbers": [4, 5, 6],
      "totalPrice": 2400,
      "paymentMethod": "cash",
      "commission": 120,
      "newWalletBalance": 5120.00
    },
    "ticketPDF": "JVBERi0xLjQKJeLjz9MKMSAwIG9iago8PC9UeXBlIC9DYXRhbG9nCi9QYWdlcyAyIDAgUgo+PgplbmRvYmoK..."
  }
}
```

**Error Responses**:

**400 Bad Request** - Missing fields:
```json
{
  "success": false,
  "message": "Missing required fields: busId, seatNumbers, passengerName, contactNumber"
}
```

**400 Bad Request** - Seats already booked:
```json
{
  "success": false,
  "message": "Seats already booked: 4, 5"
}
```

**400 Bad Request** - Seats locked by another user:
```json
{
  "success": false,
  "message": "Seats currently locked by another user: 6"
}
```

**403 Forbidden** - No access to bus:
```json
{
  "success": false,
  "message": "You do not have access to this bus"
}
```

**403 Forbidden** - Seat not allowed:
```json
{
  "success": false,
  "message": "You are not allowed to book seat(s): 10, 11"
}
```

**400 Bad Request** - Insufficient wallet balance:
```json
{
  "success": false,
  "message": "Insufficient wallet balance. Need Rs. 500.00 more"
}
```

**Notes**:
- Seats are automatically locked for 10 minutes during booking
- Lock is released after successful booking or payment failure
- Socket.IO events are emitted: `seats:locked`, `booking:created`, `seats:booked`
- Commission is automatically calculated and credited to counter wallet
- Ticket PDF is generated and returned as base64 string

---

### 5. Get All Bookings
**Endpoint**: `GET /api/counter/bookings`

**Description**: Get all bookings made by the counter with optional filters.

**Query Parameters**:
- `date` (optional): Filter by booking date
- `busId` (optional): Filter by bus ID
- `status` (optional): Filter by booking status (Confirmed/Cancelled/Completed)
- `paymentMethod` (optional): Filter by payment method (cash/online/wallet)

**Request Headers**:
```
Authorization: Bearer <token>
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "bookings": [
      {
        "_id": "507f1f77bcf86cd799439015",
        "ticketNumber": "bus-20240115-123456",
        "itemId": {
          "_id": "507f1f77bcf86cd799439012",
          "name": "Deluxe Bus",
          "from": "Kathmandu",
          "to": "Pokhara",
          "date": "2024-01-15",
          "time": "07:00"
        },
        "seatNumber": 4,
        "passengerName": "John Doe",
        "contactNumber": "9841234567",
        "passengerEmail": "john@example.com",
        "price": 800,
        "status": "Confirmed",
        "details": {
          "paymentMethod": "cash",
          "bookedBy": "counter",
          "counterName": "ABC Travels"
        },
        "createdAt": "2024-01-15T06:30:00.000Z"
      }
    ]
  }
}
```

---

### 6. Get Booking Details
**Endpoint**: `GET /api/counter/bookings/:bookingId`

**Description**: Get detailed information about a specific booking.

**URL Parameters**:
- `bookingId`: MongoDB ObjectId of the booking

**Request Headers**:
```
Authorization: Bearer <token>
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "booking": {
      "_id": "507f1f77bcf86cd799439015",
      "ticketNumber": "bus-20240115-123456",
      "itemId": {
        "_id": "507f1f77bcf86cd799439012",
        "name": "Deluxe Bus",
        "from": "Kathmandu",
        "to": "Pokhara",
        "date": "2024-01-15",
        "time": "07:00",
        "arrival": "12:00",
        "vehicleNumber": "Ba 1 Pa 1234"
      },
      "seatNumber": 4,
      "passengerName": "John Doe",
      "contactNumber": "9841234567",
      "passengerEmail": "john@example.com",
      "price": 800,
      "status": "Confirmed",
      "details": {
        "paymentMethod": "cash",
        "bookedBy": "counter",
        "counterName": "ABC Travels"
      },
      "createdAt": "2024-01-15T06:30:00.000Z"
    }
  }
}
```

**Error Response** (404 Not Found):
```json
{
  "success": false,
  "message": "Booking not found"
}
```

---

### 7. Cancel Booking
**Endpoint**: `PUT /api/counter/bookings/:bookingId/cancel`

**Description**: Cancel a booking. Refund is calculated based on cancellation timing (100% if >48h, 75% if >24h, 50% if >12h, 0% if <12h).

**URL Parameters**:
- `bookingId`: MongoDB ObjectId of the booking

**Request Headers**:
```
Authorization: Bearer <token>
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "booking": {
      "id": "507f1f77bcf86cd799439015",
      "ticketNumber": "bus-20240115-123456",
      "status": "Cancelled",
      "refundAmount": 800,
      "refundPercent": 100
    }
  }
}
```

**Error Responses**:

**400 Bad Request** - Already cancelled:
```json
{
  "success": false,
  "message": "Booking is already cancelled"
}
```

**400 Bad Request** - Cannot cancel completed:
```json
{
  "success": false,
  "message": "Cannot cancel completed booking"
}
```

**Notes**:
- Refund is automatically credited to wallet if payment was online/wallet
- Cash payments are not refunded to wallet
- Socket.IO event `booking:cancelled` is emitted
- Bus filled seats count is updated

---

## Sales & Reports

### 8. Get Sales Summary
**Endpoint**: `GET /api/counter/sales/summary`

**Description**: Get comprehensive sales summary including daily totals, cash vs online breakdown, and per-bus sales.

**Query Parameters**:
- `startDate` (optional): Start date for date range (ISO format: "2024-01-01")
- `endDate` (optional): End date for date range (ISO format: "2024-01-31")
- `busId` (optional): Filter by specific bus ID

**Note**: If no date range is provided, defaults to today's date.

**Request Headers**:
```
Authorization: Bearer <token>
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "summary": {
      "totalBookings": 45,
      "totalSales": 36000,
      "cashSales": 24000,
      "onlineSales": 10000,
      "walletSales": 2000,
      "dateRange": {
        "start": "2024-01-15",
        "end": "2024-01-15"
      }
    },
    "byBus": [
      {
        "bus": {
          "id": "507f1f77bcf86cd799439012",
          "name": "Deluxe Bus",
          "from": "Kathmandu",
          "to": "Pokhara",
          "date": "2024-01-15",
          "time": "07:00"
        },
        "bookings": 25,
        "sales": 20000,
        "cashSales": 15000,
        "onlineSales": 5000
      }
    ],
    "byDate": [
      {
        "date": "2024-01-15",
        "bookings": 45,
        "sales": 36000,
        "cashSales": 24000,
        "onlineSales": 12000
      }
    ]
  }
}
```

---

## Offline Mode

### 9. Get Offline Queue
**Endpoint**: `GET /api/counter/offline/queue`

**Description**: Get all bookings in the offline queue (pending sync).

**Request Headers**:
```
Authorization: Bearer <token>
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "queue": [
      {
        "_id": "507f1f77bcf86cd799439016",
        "busId": {
          "_id": "507f1f77bcf86cd799439012",
          "name": "Deluxe Bus",
          "from": "Kathmandu",
          "to": "Pokhara",
          "date": "2024-01-15",
          "time": "07:00"
        },
        "seatNumbers": [10, 11],
        "passengerName": "Jane Doe",
        "contactNumber": "9841234568",
        "passengerEmail": "jane@example.com",
        "paymentMethod": "cash",
        "amount": 1600,
        "status": "pending",
        "syncAttempts": 0,
        "createdAt": "2024-01-15T07:00:00.000Z"
      }
    ]
  }
}
```

**Queue Status Values**:
- `pending`: Waiting to be synced
- `synced`: Successfully synced to server
- `failed`: Sync failed (will retry)
- `conflict`: Seats already booked by another user/counter

---

### 10. Add to Offline Queue
**Endpoint**: `POST /api/counter/offline/queue`

**Description**: Add a booking to the offline queue when internet connection is unavailable. This allows counters to continue operating during network failures.

**Request Headers**:
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Request Body**:
```json
{
  "busId": "507f1f77bcf86cd799439012",
  "seatNumbers": [10, 11],
  "passengerName": "Jane Doe",
  "contactNumber": "9841234568",
  "passengerEmail": "jane@example.com",
  "paymentMethod": "cash"
}
```

**Response** (201 Created):
```json
{
  "success": true,
  "message": "Booking added to offline queue",
  "data": {
    "offlineBooking": {
      "_id": "507f1f77bcf86cd799439016",
      "counterId": "507f1f77bcf86cd799439011",
      "busId": "507f1f77bcf86cd799439012",
      "seatNumbers": [10, 11],
      "passengerName": "Jane Doe",
      "contactNumber": "9841234568",
      "passengerEmail": "jane@example.com",
      "paymentMethod": "cash",
      "amount": 1600,
      "status": "pending",
      "createdAt": "2024-01-15T07:00:00.000Z"
    }
  }
}
```

**Notes**:
- Use this endpoint when network is unavailable
- Bookings will be synced automatically when connection is restored
- Manual sync can be triggered using the sync endpoint

---

### 11. Sync Offline Bookings
**Endpoint**: `POST /api/counter/offline/sync`

**Description**: Manually trigger synchronization of all pending offline bookings. This endpoint attempts to create bookings from the offline queue.

**Request Headers**:
```
Authorization: Bearer <token>
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Synced 3 booking(s)",
  "data": {
    "synced": 3,
    "failed": 0,
    "conflicts": 0,
    "errors": []
  }
}
```

**Response with Conflicts**:
```json
{
  "success": true,
  "message": "Synced 2 booking(s)",
  "data": {
    "synced": 2,
    "failed": 1,
    "conflicts": 1,
    "errors": [
      {
        "offlineBookingId": "507f1f77bcf86cd799439016",
        "error": "Seats already booked: 10, 11"
      }
    ]
  }
}
```

**Notes**:
- Syncs all pending bookings in the queue
- Checks for seat availability before creating bookings
- Marks conflicts if seats are already booked
- Updates sync attempts and error messages
- Logs all sync actions for audit

---

## Audit Logs

### 12. Get Audit Logs
**Endpoint**: `GET /api/counter/audit-logs`

**Description**: Get audit logs for all counter actions. Useful for tracking all operations, fraud prevention, and reconciliation.

**Query Parameters**:
- `action` (optional): Filter by action type (booking_created, booking_cancelled, seat_locked, etc.)
- `startDate` (optional): Start date for date range (ISO format)
- `endDate` (optional): End date for date range (ISO format)
- `limit` (optional): Maximum number of logs to return (default: 100)

**Request Headers**:
```
Authorization: Bearer <token>
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "logs": [
      {
        "_id": "507f1f77bcf86cd799439017",
        "counterId": "507f1f77bcf86cd799439011",
        "action": "booking_created",
        "busId": {
          "_id": "507f1f77bcf86cd799439012",
          "name": "Deluxe Bus",
          "from": "Kathmandu",
          "to": "Pokhara"
        },
        "bookingId": {
          "_id": "507f1f77bcf86cd799439015",
          "ticketNumber": "bus-20240115-123456"
        },
        "details": {
          "busId": "507f1f77bcf86cd799439012",
          "busName": "Deluxe Bus",
          "seatNumbers": [4, 5, 6],
          "ticketNumber": "bus-20240115-123456",
          "paymentMethod": "cash",
          "amount": 2400,
          "commission": 120
        },
        "ipAddress": "192.168.1.100",
        "userAgent": "Mozilla/5.0...",
        "createdAt": "2024-01-15T07:00:00.000Z"
      }
    ]
  }
}
```

**Action Types**:
- `booking_created`: New booking created
- `booking_cancelled`: Booking cancelled
- `seat_locked`: Seat locked (temporary)
- `seat_unlocked`: Seat unlocked
- `payment_received`: Payment processed
- `ticket_printed`: Ticket printed
- `offline_sync`: Offline booking synced
- `access_denied`: Access denied attempt
- `profile_updated`: Profile updated

---

## Error Responses

All endpoints follow a consistent error response format:

**400 Bad Request**:
```json
{
  "success": false,
  "message": "Error message describing what went wrong"
}
```

**401 Unauthorized**:
```json
{
  "success": false,
  "message": "Not authorized, token failed"
}
```

**403 Forbidden**:
```json
{
  "success": false,
  "message": "You do not have access to this resource"
}
```

**404 Not Found**:
```json
{
  "success": false,
  "message": "Resource not found"
}
```

**500 Internal Server Error**:
```json
{
  "success": false,
  "message": "Failed to process request",
  "error": "Detailed error information (development only)"
}
```

---

## Socket.IO Events

The counter system uses Socket.IO for real-time updates. Counters should listen to these events:

### Events Emitted by Server:

1. **`seats:locked`** - When seats are locked by any user/counter
   ```json
   {
     "busId": "507f1f77bcf86cd799439012",
     "seatNumbers": [4, 5, 6],
     "lockedBy": "507f1f77bcf86cd799439011",
     "lockedByType": "BusAgent",
     "expiresAt": "2024-01-15T07:10:00.000Z"
   }
   ```

2. **`seats:booked`** - When seats are confirmed as booked
   ```json
   {
     "busId": "507f1f77bcf86cd799439012",
     "seatNumbers": [4, 5, 6]
   }
   ```

3. **`booking:created`** - When a new booking is created
   ```json
   {
     "busId": "507f1f77bcf86cd799439012",
     "seatNumbers": [4, 5, 6],
     "ticketNumber": "bus-20240115-123456"
   }
   ```

4. **`booking:cancelled`** - When a booking is cancelled
   ```json
   {
     "busId": "507f1f77bcf86cd799439012",
     "seatNumber": 4,
     "ticketNumber": "bus-20240115-123456"
   }
   ```

### Events to Emit from Client:

Counters can emit events to request real-time updates (optional):
- `subscribe:bus:<busId>` - Subscribe to updates for a specific bus
- `unsubscribe:bus:<busId>` - Unsubscribe from bus updates

---

## Integration Notes

### Seat Locking Flow:
1. Counter selects seats → System locks seats (10-minute expiration)
2. Lock broadcasted to all users/counters via Socket.IO
3. Payment processed → Booking confirmed → Lock released
4. If payment fails → Lock released automatically

### Offline Mode Flow:
1. Network unavailable → Counter adds booking to offline queue
2. Queue stored locally and on server (when connection available)
3. When connection restored → Automatic or manual sync
4. Server validates seat availability → Creates booking or marks conflict

### Commission Calculation:
- Commission = `bus.commissionRate * bus.price * seatCount`
- Automatically credited to counter wallet
- Tracked in `AgentBusAccess.commissionEarned`

### Refund Policy:
- **>48 hours before departure**: 100% refund
- **24-48 hours before departure**: 75% refund
- **12-24 hours before departure**: 50% refund
- **<12 hours before departure**: 0% refund

---

## Testing Checklist

- [ ] Dashboard loads with assigned buses
- [ ] Bus list filters work (date, route, status)
- [ ] Real-time seat availability updates correctly
- [ ] Seat locking prevents double booking
- [ ] Booking creation with cash payment
- [ ] Booking creation with wallet payment
- [ ] Booking creation with online payment
- [ ] Booking cancellation with refund calculation
- [ ] Sales summary shows correct totals
- [ ] Offline queue stores bookings correctly
- [ ] Offline sync creates bookings successfully
- [ ] Audit logs capture all actions
- [ ] Socket.IO events broadcast correctly
- [ ] Access control prevents unauthorized bus access
- [ ] Allowed seats restriction works correctly

---

**Last Updated**: 2024-01-15
**Version**: 1.0.0

