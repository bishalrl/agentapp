# Driver Features - Complete Backend Requirements

This document outlines all backend APIs, data structures, and permissions management needed to support the driver features implemented in the frontend.

---

## Table of Contents

1. [Permission Management](#1-permission-management)
2. [Ride Management APIs](#2-ride-management-apis)
3. [Booking APIs](#3-booking-apis)
4. [Scan/Ticket Verification APIs](#4-scanticket-verification-apis)
5. [Bus Details & Seat Map APIs](#5-bus-details--seat-map-apis)
6. [Profile & Permission Request APIs](#6-profile--permission-request-apis)
7. [Database Schema Updates](#7-database-schema-updates)
8. [Real-time Updates](#8-real-time-updates)

---

## 1. Permission Management

### 1.1 Driver Permission Structure

**Driver Model - Add Permission Fields:**
```javascript
{
  // ... existing driver fields ...
  
  permissions: {
    canCreateBooking: {
      type: Boolean,
      default: false,
    },
    canViewReports: {
      type: Boolean,
      default: false,
    },
    // Add other permissions as needed
  },
  
  // Permission requests from driver
  permissionRequests: [{
    type: {
      type: String,
      enum: ['booking', 'reports', 'other'],
      required: true,
    },
    status: {
      type: String,
      enum: ['pending', 'approved', 'rejected'],
      default: 'pending',
    },
    requestedAt: {
      type: Date,
      default: Date.now,
    },
    reviewedAt: Date,
    reviewedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Owner',
    },
    message: String, // Optional message from driver
  }],
}
```

### 1.2 Bus Access Permission Structure

**DriverBusAccess Model (or similar):**
```javascript
{
  driverId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Driver',
    required: true,
  },
  busId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Bus',
    required: true,
  },
  ownerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Owner',
    required: true,
  },
  
  // Permissions for this specific bus
  permissions: {
    canCreateBooking: {
      type: Boolean,
      default: false,
    },
    canViewPassengers: {
      type: Boolean,
      default: true, // Drivers can always view passengers
    },
    canVerifyTickets: {
      type: Boolean,
      default: true, // Drivers can always verify tickets
    },
  },
  
  // Seat restrictions (if any)
  allowedSeats: [{
    type: Number,
  }],
  
  createdAt: {
    type: Date,
    default: Date.now,
  },
}
```

### 1.3 Permission Check Logic

**In Driver Dashboard API (`GET /api/driver/dashboard`):**
```javascript
// Include permission information in response
{
  "success": true,
  "data": {
    "driver": {
      "_id": "...",
      "name": "...",
      "permissions": {
        "canCreateBooking": true/false
      }
    },
    "buses": [
      {
        "_id": "...",
        "name": "...",
        // ... other bus fields ...
        "driverBusAccess": {
          "permissions": {
            "canCreateBooking": true/false
          },
          "allowedSeats": [1, 2, 3] // or null for all seats
        }
      }
    ]
  }
}
```

---

## 2. Ride Management APIs

### 2.1 Initiate Ride

**Endpoint:** `POST /api/driver/ride/initiate`

**Headers:** `Authorization: Bearer <driver_token>`

**Request Body:**
```json
{
  "busId": "6967797def090e45c537ebfe"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Ride initiated successfully",
  "data": {
    "bus": {
      "_id": "6967797def090e45c537ebfe",
      "name": "Deluxe Bus",
      "vehicleNumber": "BA-1234",
      "from": "Kathmandu",
      "to": "Pokhara",
      "date": "2024-01-15",
      "time": "06:00 AM",
      "arrival": "02:00 PM"
    },
    "route": {
      "from": {
        "name": "Kathmandu",
        "coordinates": {
          "latitude": 27.7172,
          "longitude": 85.3240
        }
      },
      "to": {
        "name": "Pokhara",
        "coordinates": {
          "latitude": 28.2096,
          "longitude": 83.9856
        }
      },
      "stops": [
        {
          "name": "Stop 1",
          "order": 1,
          "coordinates": {
            "latitude": 27.7172,
            "longitude": 85.3240
          },
          "distanceFromStart": 0,
          "estimatedTimeFromStart": 0
        }
      ],
      "boardingPoints": [
        {
          "location": "New Bus Park",
          "time": "06:00 AM",
          "coordinates": {
            "latitude": 27.7172,
            "longitude": 85.3240
          }
        }
      ],
      "stoppingPoints": [
        {
          "location": "Pokhara Bus Park",
          "time": "02:00 PM",
          "coordinates": {
            "latitude": 28.2096,
            "longitude": 83.9856
          }
        }
      ],
      "totalDistance": 200,
      "estimatedDuration": 480
    },
    "tripStatus": "in_transit",
    "initiatedAt": "2024-01-15T06:00:00Z"
  }
}
```

**Backend Implementation Requirements:**
- Verify driver is assigned to the bus (`assignedBusIds` contains `busId`)
- Update bus `tripStatus` to `"in_transit"`
- Fetch route information from `Route` model (if exists)
- Extract GPS coordinates from route stops, boarding points, stopping points
- Return complete route data with all coordinates for map display
- Store ride initiation timestamp

**Error Responses:**
- `403 Forbidden`: Driver not assigned to this bus
- `404 Not Found`: Bus not found
- `400 Bad Request`: Bus already in transit or invalid state

---

### 2.2 Update Driver Location

**Endpoint:** `POST /api/driver/location/update`

**Headers:** `Authorization: Bearer <driver_token>`

**Request Body:**
```json
{
  "busId": "6967797def090e45c537ebfe",
  "latitude": 27.7172,
  "longitude": 85.3240,
  "speed": 60,
  "heading": 90,
  "accuracy": 10
}
```

**Response:**
```json
{
  "success": true,
  "message": "Location updated successfully",
  "data": {
    "location": {
      "_id": "location_id",
      "latitude": 27.7172,
      "longitude": 85.3240,
      "speed": 60,
      "heading": 90,
      "accuracy": 10,
      "timestamp": "2024-01-15T06:05:00Z"
    }
  }
}
```

**Backend Implementation Requirements:**
- Verify driver is assigned to the bus
- Verify bus is in `"in_transit"` status
- Store location in `BusLocation` collection:
  ```javascript
  {
    busId: ObjectId,
    driverId: ObjectId,
    latitude: Number,
    longitude: Number,
    speed: Number, // km/h
    heading: Number, // degrees 0-360
    accuracy: Number, // meters
    timestamp: Date,
  }
  ```
- Implement TTL index to auto-delete locations older than 7 days
- Optional: Emit Socket.IO event for real-time tracking
- Rate limiting: Accept updates every 5-10 seconds (reject if too frequent)

**Error Responses:**
- `403 Forbidden`: Driver not assigned to bus
- `400 Bad Request`: Bus not in transit or invalid coordinates
- `429 Too Many Requests`: Location updates too frequent

---

## 3. Booking APIs

### 3.1 Create Driver Booking

**Endpoint:** `POST /api/driver/bookings`

**Headers:** `Authorization: Bearer <driver_token>`

**Request Body:**
```json
{
  "busId": "6967797def090e45c537ebfe",
  "seatNumbers": [1, 2],
  "passengerName": "John Doe",
  "contactNumber": "9876543210",
  "passengerEmail": "john@example.com",
  "pickupLocation": "New Bus Park",
  "dropoffLocation": "Pokhara Bus Park",
  "luggage": "2 bags",
  "bagCount": 2,
  "paymentMethod": "cash"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Booking created successfully",
  "data": {
    "ticketNumber": "bus-20240115-123456",
    "seatNumbers": [1, 2],
    "totalPrice": 3000,
    "paymentMethod": "cash",
    "bookings": [
      {
        "id": "booking_id_1",
        "seatNumber": 1,
        "passengerName": "John Doe"
      },
      {
        "id": "booking_id_2",
        "seatNumber": 2,
        "passengerName": "John Doe"
      }
    ]
  }
}
```

**Backend Implementation Requirements:**

1. **Permission Validation:**
   ```javascript
   // Check driver has booking permission
   const driver = await Driver.findById(driverId);
   const busAccess = await DriverBusAccess.findOne({ driverId, busId });
   
   const hasPermission = 
     driver.permissions?.canCreateBooking === true ||
     busAccess?.permissions?.canCreateBooking === true;
   
   if (!hasPermission) {
     return res.status(403).json({
       success: false,
       message: "Driver does not have permission to create bookings"
     });
   }
   ```

2. **Seat Validation:**
   ```javascript
   // If driver has restricted seats, validate against allowedSeats
   if (busAccess?.allowedSeats && busAccess.allowedSeats.length > 0) {
     const invalidSeats = seatNumbers.filter(seat => 
       !busAccess.allowedSeats.includes(seat)
     );
     
     if (invalidSeats.length > 0) {
       return res.status(400).json({
         success: false,
         message: `Seats ${invalidSeats.join(', ')} are not allowed for this driver`
       });
     }
   }
   ```

3. **Seat Availability Check:**
   - Check seats are not already booked
   - Check seats are not locked by another counter/driver
   - Normalize seat numbers (handle both int and string formats)

4. **Booking Creation:**
   - Create booking records (one per seat)
   - Generate ticket number
   - Set `bookedBy` field to driver ID
   - Set `bookedByType` to `"driver"`
   - Calculate total price
   - Handle payment method

5. **Post-Booking Actions:**
   - Unlock any locked seats
   - Emit Socket.IO notification
   - Generate QR code (usually ticket number)
   - Return booking details

**Error Responses:**
- `403 Forbidden`: Driver not assigned to bus or no permission
- `400 Bad Request`: Seats already booked or invalid seat numbers
- `400 Bad Request`: Seats not in allowedSeats (if restricted access)

---

## 4. Scan/Ticket Verification APIs

### 4.1 Get Bus Passengers

**Endpoint:** `GET /api/driver/bus/:busId/passengers`

**Headers:** `Authorization: Bearer <driver_token>`

**Response:**
```json
{
  "success": true,
  "data": {
    "bus": {
      "_id": "6967797def090e45c537ebfe",
      "name": "Deluxe Bus",
      "vehicleNumber": "BA-1234",
      "from": "Kathmandu",
      "to": "Pokhara",
      "date": "2024-01-15",
      "time": "06:00 AM",
      "totalSeats": 40
    },
    "passengers": [
      {
        "bookingId": "booking_id_1",
        "ticketNumber": "bus-20240115-123456",
        "seatNumber": 1,
        "passengerName": "John Doe",
        "contactNumber": "9876543210",
        "passengerEmail": "john@example.com",
        "pickupLocation": "New Bus Park",
        "dropoffLocation": "Pokhara Bus Park",
        "luggage": "2 bags",
        "bagCount": 2,
        "ticketVerified": false,
        "verifiedAt": null,
        "verifiedBy": null,
        "qrCode": "bus-20240115-123456"
      },
      {
        "bookingId": "booking_id_2",
        "ticketNumber": "bus-20240115-123456",
        "seatNumber": 2,
        "passengerName": "Jane Doe",
        "contactNumber": "9876543211",
        "passengerEmail": null,
        "pickupLocation": "New Bus Park",
        "dropoffLocation": "Pokhara Bus Park",
        "luggage": null,
        "bagCount": 0,
        "ticketVerified": true,
        "verifiedAt": "2024-01-15T06:10:00Z",
        "verifiedBy": "driver_id",
        "qrCode": "bus-20240115-123456"
      }
    ],
    "totalPassengers": 2,
    "verifiedPassengers": 1,
    "unverifiedPassengers": 1
  }
}
```

**Backend Implementation Requirements:**
- Verify driver is assigned to the bus
- Fetch all confirmed bookings for the bus
- Include verification status (`ticketVerified`, `verifiedAt`, `verifiedBy`)
- Sort passengers by seat number
- Calculate statistics (total, verified, unverified)
- Return passenger details (no masking - driver needs full info)

**Error Responses:**
- `403 Forbidden`: Driver not assigned to bus
- `404 Not Found`: Bus not found

---

### 4.2 Verify Ticket

**Endpoint:** `POST /api/driver/scan/verify-ticket`

**Headers:** `Authorization: Bearer <driver_token>`

**Request Body:**
```json
{
  "qrCode": "bus-20240115-123456",
  "busId": "6967797def090e45c537ebfe",
  "seatNumber": 1
}
```

**Response (Success - First Verification):**
```json
{
  "success": true,
  "message": "Ticket verified successfully",
  "alreadyVerified": false,
  "data": {
    "booking": {
      "ticketNumber": "bus-20240115-123456",
      "seatNumber": 1,
      "passengerName": "John Doe",
      "contactNumber": "9876543210",
      "passengerEmail": "john@example.com",
      "pickupLocation": "New Bus Park",
      "dropoffLocation": "Pokhara Bus Park",
      "luggage": "2 bags",
      "bagCount": 2,
      "verifiedAt": "2024-01-15T06:10:00Z",
      "verifiedBy": "driver_id"
    }
  }
}
```

**Response (Already Verified):**
```json
{
  "success": true,
  "message": "Ticket already verified",
  "alreadyVerified": true,
  "data": {
    "booking": {
      "ticketNumber": "bus-20240115-123456",
      "seatNumber": 1,
      "passengerName": "John Doe",
      "contactNumber": "9876543210",
      "verifiedAt": "2024-01-15T06:05:00Z",
      "verifiedBy": "driver_id"
    }
  }
}
```

**Response (Seat Mismatch):**
```json
{
  "success": false,
  "message": "Seat number mismatch. Ticket is for seat 1, but scanned for seat 2",
  "booking": {
    "ticketNumber": "bus-20240115-123456",
    "seatNumber": 1,
    "passengerName": "John Doe"
  }
}
```

**Backend Implementation Requirements:**

1. **QR Code Lookup:**
   ```javascript
   // Find booking by QR code (ticket number or booking ID)
   const booking = await Booking.findOne({
     $or: [
       { ticketNumber: qrCode },
       { _id: qrCode },
       { qrCode: qrCode }
     ],
     busId: busId,
     status: 'confirmed'
   });
   ```

2. **Validation:**
   - Verify booking belongs to the bus
   - Verify driver is assigned to the bus
   - Optional: Verify seat number matches (if provided)

3. **Verification Logic:**
   ```javascript
   if (booking.ticketVerified) {
     // Already verified - return success with alreadyVerified flag
     return res.json({
       success: true,
       message: "Ticket already verified",
       alreadyVerified: true,
       data: { booking }
     });
   }
   
   // First verification
   booking.ticketVerified = true;
   booking.verifiedAt = new Date();
   booking.verifiedBy = driverId;
   await booking.save();
   
   return res.json({
     success: true,
     message: "Ticket verified successfully",
     alreadyVerified: false,
     data: { booking }
   });
   ```

4. **Seat Mismatch Handling:**
   - If `seatNumber` provided and doesn't match booking seat, return warning
   - Still allow verification but include mismatch message

**Error Responses:**
- `404 Not Found`: Ticket not found or invalid QR code
- `400 Bad Request`: Seat number mismatch (if strict validation)
- `403 Forbidden`: Driver not assigned to bus
- `400 Bad Request`: Booking not confirmed or cancelled

---

## 5. Bus Details & Seat Map APIs

### 5.1 Get Bus Details (for Seat Map)

**Endpoint:** `GET /api/driver/bus/:busId`

**Headers:** `Authorization: Bearer <driver_token>`

**Response:**
```json
{
  "success": true,
  "data": {
    "bus": {
      "_id": "6967797def090e45c537ebfe",
      "name": "Deluxe Bus",
      "vehicleNumber": "BA-1234",
      "from": "Kathmandu",
      "to": "Pokhara",
      "date": "2024-01-15",
      "time": "06:00 AM",
      "totalSeats": 40,
      "seatConfiguration": ["1", "2", "3", "A1", "A2", ...], // or null for sequential
      "bookedSeats": [1, 2, 5, 10],
      "lockedSeats": [
        {
          "seatNumber": 3,
          "lockedBy": "counter_id",
          "expiresAt": "2024-01-15T06:15:00Z"
        }
      ],
      "filledSeats": 4,
      "availableSeats": 36
    },
    "seats": [
      {
        "seatNumber": 1,
        "isBooked": true,
        "passenger": {
          "name": "John Doe",
          "contactNumber": "9876543210",
          "ticketNumber": "bus-20240115-123456",
          "ticketVerified": false
        }
      },
      {
        "seatNumber": 2,
        "isBooked": false,
        "passenger": null
      }
    ]
  }
}
```

**Backend Implementation Requirements:**
- Verify driver is assigned to the bus
- Return complete seat map with passenger information
- Include `seatConfiguration` if custom seat identifiers exist
- Include `bookedSeats` array (normalized to numbers where possible)
- Include `lockedSeats` with lock details
- For each seat, include passenger info if booked
- Return seat-by-seat array for easy mapping

**Error Responses:**
- `403 Forbidden`: Driver not assigned to bus
- `404 Not Found`: Bus not found

---

## 6. Profile & Permission Request APIs

### 6.1 Request Booking Permission

**Endpoint:** `POST /api/driver/permissions/request`

**Headers:** `Authorization: Bearer <driver_token>`

**Request Body:**
```json
{
  "permissionType": "booking",
  "message": "I would like to request permission to create bookings for passengers."
}
```

**Response:**
```json
{
  "success": true,
  "message": "Permission request sent to owner",
  "data": {
    "request": {
      "_id": "request_id",
      "permissionType": "booking",
      "status": "pending",
      "requestedAt": "2024-01-15T06:00:00Z",
      "message": "..."
    }
  }
}
```

**Backend Implementation Requirements:**

1. **Create Permission Request:**
   ```javascript
   const driver = await Driver.findById(driverId);
   const inviter = await Owner.findById(driver.invitedBy); // or Counter
   
   const request = await PermissionRequest.create({
     driverId: driverId,
     ownerId: inviter._id,
     permissionType: 'booking',
     message: req.body.message,
     status: 'pending',
     requestedAt: new Date()
   });
   ```

2. **Notify Owner:**
   - Send notification/email to owner
   - Optional: Emit Socket.IO event
   - Include driver details and request message

3. **Owner Approval Flow:**
   - Owner reviews request via admin panel
   - Owner approves/rejects via API:
     ```
     PUT /api/owner/permission-requests/:requestId/approve
     PUT /api/owner/permission-requests/:requestId/reject
     ```
   - On approval: Update driver permissions or bus access permissions
   - Notify driver of decision

**Error Responses:**
- `400 Bad Request`: Invalid permission type
- `400 Bad Request`: Request already pending
- `404 Not Found`: Owner/inviter not found

---

### 6.2 Get Permission Requests (Driver)

**Endpoint:** `GET /api/driver/permissions/requests`

**Headers:** `Authorization: Bearer <driver_token>`

**Response:**
```json
{
  "success": true,
  "data": {
    "requests": [
      {
        "_id": "request_id",
        "permissionType": "booking",
        "status": "pending",
        "requestedAt": "2024-01-15T06:00:00Z",
        "reviewedAt": null,
        "message": "..."
      }
    ]
  }
}
```

---

## 7. Database Schema Updates

### 7.1 Booking Model - Add Verification Fields

```javascript
{
  // ... existing booking fields ...
  
  // Ticket verification fields
  ticketVerified: {
    type: Boolean,
    default: false,
  },
  verifiedAt: {
    type: Date,
    default: null,
  },
  verifiedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Driver',
    default: null,
  },
  qrCode: {
    type: String,
    default: null, // Usually ticketNumber, can be custom
  },
  
  // Booking source tracking
  bookedBy: {
    type: mongoose.Schema.Types.ObjectId,
    refPath: 'bookedByType',
  },
  bookedByType: {
    type: String,
    enum: ['Counter', 'Driver', 'Owner'],
    default: 'Counter',
  },
}
```

### 7.2 Bus Model - Add Trip Status

```javascript
{
  // ... existing bus fields ...
  
  tripStatus: {
    type: String,
    enum: ['scheduled', 'in_transit', 'completed', 'cancelled'],
    default: 'scheduled',
  },
  
  rideInitiatedAt: {
    type: Date,
    default: null,
  },
  
  rideInitiatedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Driver',
    default: null,
  },
}
```

### 7.3 BusLocation Collection (New)

```javascript
{
  busId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Bus',
    required: true,
    index: true,
  },
  driverId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Driver',
    required: true,
  },
  latitude: {
    type: Number,
    required: true,
  },
  longitude: {
    type: Number,
    required: true,
  },
  speed: {
    type: Number, // km/h
  },
  heading: {
    type: Number, // degrees 0-360
  },
  accuracy: {
    type: Number, // meters
  },
  timestamp: {
    type: Date,
    default: Date.now,
    index: true,
    expires: 604800, // 7 days TTL
  },
}
```

### 7.4 PermissionRequest Collection (New)

```javascript
{
  driverId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Driver',
    required: true,
  },
  ownerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Owner',
    required: true,
  },
  permissionType: {
    type: String,
    enum: ['booking', 'reports', 'other'],
    required: true,
  },
  status: {
    type: String,
    enum: ['pending', 'approved', 'rejected'],
    default: 'pending',
  },
  message: String,
  requestedAt: {
    type: Date,
    default: Date.now,
  },
  reviewedAt: Date,
  reviewedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Owner',
  },
  reviewMessage: String, // Optional message from owner
}
```

### 7.5 Route Model (if not exists)

```javascript
{
  busId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Bus',
    required: true,
  },
  from: {
    name: String,
    coordinates: {
      latitude: Number,
      longitude: Number,
    },
  },
  to: {
    name: String,
    coordinates: {
      latitude: Number,
      longitude: Number,
    },
  },
  stops: [{
    name: String,
    order: Number,
    coordinates: {
      latitude: Number,
      longitude: Number,
    },
    distanceFromStart: Number, // km
    estimatedTimeFromStart: Number, // minutes
  }],
  boardingPoints: [{
    location: String,
    time: String,
    coordinates: {
      latitude: Number,
      longitude: Number,
    },
  }],
  stoppingPoints: [{
    location: String,
    time: String,
    coordinates: {
      latitude: Number,
      longitude: Number,
    },
  }],
  totalDistance: Number, // km
  estimatedDuration: Number, // minutes
}
```

---

## 8. Real-time Updates

### 8.1 Socket.IO Events

**Emit Events:**

1. **Location Update:**
   ```javascript
   io.emit('bus-location-update', {
     busId: busId,
     latitude: latitude,
     longitude: longitude,
     timestamp: new Date(),
   });
   ```

2. **Ticket Verified:**
   ```javascript
   io.to(`bus-${busId}`).emit('ticket-verified', {
     bookingId: bookingId,
     seatNumber: seatNumber,
     verifiedBy: driverId,
   });
   ```

3. **Booking Created (Driver):**
   ```javascript
   io.to(`bus-${busId}`).emit('booking-created', {
     bookingId: bookingId,
     seatNumbers: seatNumbers,
     bookedBy: 'driver',
   });
   ```

**Subscribe Events:**
- Drivers can subscribe to `bus-${busId}` room for real-time updates
- Owners/counters can subscribe for location tracking

---

## 9. API Endpoint Summary

### Required Endpoints:

| Method | Endpoint | Purpose | Status |
|--------|----------|---------|--------|
| POST | `/api/driver/ride/initiate` | Initiate ride and get route | ✅ Required |
| POST | `/api/driver/location/update` | Update driver GPS location | ✅ Required |
| POST | `/api/driver/bookings` | Create booking as driver | ✅ Required |
| GET | `/api/driver/bus/:busId/passengers` | Get passenger list | ✅ Required |
| POST | `/api/driver/scan/verify-ticket` | Verify ticket via QR code | ✅ Required |
| GET | `/api/driver/bus/:busId` | Get bus details with seat map | ✅ Required |
| POST | `/api/driver/permissions/request` | Request permission from owner | ✅ Required |
| GET | `/api/driver/permissions/requests` | Get permission requests | ✅ Required |
| GET | `/api/driver/dashboard` | Get dashboard with permissions | ✅ Update Required |

### Owner Endpoints (for Permission Management):

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/owner/permission-requests` | Get all permission requests |
| PUT | `/api/owner/permission-requests/:requestId/approve` | Approve permission request |
| PUT | `/api/owner/permission-requests/:requestId/reject` | Reject permission request |

---

## 10. Validation & Security

### 10.1 Driver Assignment Validation

**Always verify driver is assigned to bus:**
```javascript
const driver = await Driver.findById(driverId);
if (!driver.assignedBusIds.includes(busId)) {
  return res.status(403).json({
    success: false,
    message: "Driver is not assigned to this bus"
  });
}
```

### 10.2 Permission Validation

**Check permissions before allowing actions:**
```javascript
// For booking creation
const hasPermission = 
  driver.permissions?.canCreateBooking === true ||
  busAccess?.permissions?.canCreateBooking === true;

if (!hasPermission) {
  return res.status(403).json({
    success: false,
    message: "Driver does not have permission to create bookings"
  });
}
```

### 10.3 Seat Number Normalization

**Normalize seat numbers consistently:**
```javascript
function normalizeSeatNumber(seat) {
  if (typeof seat === 'number') return seat;
  if (typeof seat === 'string') {
    const num = parseInt(seat.trim());
    if (!isNaN(num) && num.toString() === seat.trim()) {
      return num; // Pure numeric string -> number
    }
    return seat.trim(); // Non-numeric string -> keep as string
  }
  return seat;
}
```

---

## 11. Testing Checklist

### Backend Testing:

- [ ] Driver can initiate ride only for assigned buses
- [ ] Route data includes GPS coordinates for all stops
- [ ] Location updates are stored correctly
- [ ] Location updates rate-limited (5-10 seconds)
- [ ] Driver can create bookings only with permission
- [ ] Seat validation works for restricted access
- [ ] Passenger list includes verification status
- [ ] Ticket verification updates booking correctly
- [ ] QR code lookup works with ticket number and booking ID
- [ ] Permission requests are created and sent to owner
- [ ] Owner can approve/reject permission requests
- [ ] Bus details include complete seat map with passenger info
- [ ] Seat numbers are normalized consistently

---

## 12. Important Notes

1. **Permission Hierarchy:**
   - Global driver permission (`driver.permissions.canCreateBooking`) overrides bus-specific
   - Bus-specific permission (`busAccess.permissions.canCreateBooking`) applies only to that bus
   - If neither exists, driver cannot book

2. **Seat Access:**
   - If `busAccess.allowedSeats` is `null` or empty → driver can book all seats (if has permission)
   - If `busAccess.allowedSeats` has values → driver can only book those seats
   - Seat numbers must be normalized (int vs string) for comparison

3. **QR Code Format:**
   - Default: Ticket number (e.g., `"bus-20240115-123456"`)
   - Can be booking ID
   - Can be custom `qrCode` field in booking
   - Backend should check all three formats

4. **Location Tracking:**
   - Store locations in separate collection with TTL
   - Don't store in Bus model (too much data)
   - Use TTL index for auto-cleanup
   - Consider rate limiting to prevent spam

5. **Route Data:**
   - If Route model exists, fetch from there
   - If not, extract from Bus model fields (`from`, `to`, `stops`)
   - Always include GPS coordinates for map display

---

**Last Updated:** 2024-01-15  
**Version:** 1.0.0
