# Driver API Documentation

Complete API reference for the Driver application. Includes OTP-based invitation and association flow.

**Base URL:** `/api/driver`

---

## Table of Contents

1. [Authentication & Registration](#authentication--registration)
2. [OTP Flow](#otp-flow)
3. [Profile Management](#profile-management)
4. [Bus Management](#bus-management)
5. [Trip Management](#trip-management)
6. [Location Sharing](#location-sharing)
7. [Request Management](#request-management)

---

## Authentication & Registration

### Register Driver
**POST** `/api/driver/register`

Register a new driver. Can optionally associate with owner using OTP.

**Content-Type:** `multipart/form-data`

**Form Fields:**
- `name` (required): Driver name
- `email` (required): Driver email address
- `phoneNumber` (required): Driver phone number
- `password` (required): Password
- `licenseNumber` (required): License number
- `licensePhoto` (required): License photo file
- `driverPhoto` (required): Driver photo file
- `hasOTP` (optional): Boolean - true if driver has OTP
- `otp` (optional): OTP code for owner association

**Response:**
```json
{
  "success": true,
  "message": "Driver registered successfully and associated with owner",
  "data": {
    "driver": {
      "id": "driver_id",
      "name": "Driver Name",
      "email": "driver@example.com",
      "phoneNumber": "9876543210",
      "licenseNumber": "LIC123456",
      "associatedWithOwner": true,
      "ownerName": "ABC Transport"
    },
    "token": "jwt_token_here"
  }
}
```

**OTP Flow:**
- If `hasOTP: true` and `otp` provided, system validates OTP
- If valid, driver is automatically associated with the owner who sent the invitation
- OTP is cleared after successful association

---

### Register with Invitation Code
**POST** `/api/driver/register-with-invitation`

Register using invitation code (legacy method).

**Content-Type:** `multipart/form-data`

**Form Fields:**
- `invitationCode` (required): Invitation code
- `name` (required): Driver name
- `email` (required): Email
- `phoneNumber` (required): Phone number
- `password` (required): Password
- `licenseNumber` (required): License number
- `licensePhoto` (required): License photo file
- `driverPhoto` (required): Driver photo file

---

### Login Driver
**POST** `/api/driver/login`

Login with email/phone and password. Can optionally associate with owner using OTP.

**Request Body:**
```json
{
  "email": "driver@example.com",
  "phoneNumber": "9876543210",
  "password": "password123",
  "hasOTP": true,
  "otp": "123456"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Login successful and associated with owner",
  "data": {
    "driver": {
      "id": "driver_id",
      "name": "Driver Name",
      "email": "driver@example.com",
      "phoneNumber": "9876543210",
      "licenseNumber": "LIC123456",
      "associatedWithOwner": true,
      "ownerName": "ABC Transport"
    },
    "token": "jwt_token_here"
  }
}
```

**OTP Flow:**
- If `hasOTP: true` and `otp` provided, system validates OTP after login
- If valid, driver is associated with owner
- Login succeeds even if OTP validation fails (warning logged)

---

### Verify OTP
**POST** `/api/driver/verify-otp`

Verify OTP and authenticate (standalone OTP verification).

**Request Body:**
```json
{
  "phoneNumber": "9876543210",
  "otp": "123456"
}
```

**Response:**
```json
{
  "success": true,
  "message": "OTP verified successfully",
  "data": {
    "token": "jwt_token_here",
    "driver": {
      "id": "driver_id",
      "name": "Driver Name",
      "assignedBusIds": []
    }
  }
}
```

---

## OTP Flow

### How OTP Works

1. **Owner/Counter Invites Driver:**
   - Owner adds driver with email: `POST /api/owner/staff/driver`
   - System generates 6-digit OTP
   - OTP is sent to driver's email
   - OTP expires in 24 hours

2. **Driver Receives OTP:**
   - Driver receives email with OTP
   - Email includes owner name and instructions

3. **Driver Registers/Logs In:**
   - During registration: Provide `hasOTP: true` and `otp: "123456"`
   - During login: Provide `hasOTP: true` and `otp: "123456"`
   - System validates OTP and associates driver with owner
   - OTP is cleared after successful association

4. **Association:**
   - Driver is linked to owner via `invitedBy` and `invitedByType: "BusOwner"`
   - Driver status updated to `REGISTERED` if was `INVITED`
   - Driver can now be assigned to owner's buses

---

## Profile Management

### Get Profile
**GET** `/api/driver/profile`

Get driver profile with assigned buses.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "success": true,
  "data": {
    "_id": "driver_id",
    "name": "Driver Name",
    "email": "driver@example.com",
    "phoneNumber": "9876543210",
    "licenseNumber": "LIC123456",
    "status": "REGISTERED",
    "isVerified": true,
    "isActive": true,
    "assignedBusId": "bus_id",
    "assignedBusIds": ["bus_id1", "bus_id2"],
    "invitedBy": "owner_id",
    "invitedByType": "BusOwner",
    "licensePhoto": "/uploads/images/license.jpg",
    "driverPhoto": "/uploads/images/driver.jpg"
  }
}
```

---

### Update Profile
**PUT** `/api/driver/profile`

Update driver profile.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "Updated Name",
  "email": "updated@example.com"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": { /* updated driver */ }
}
```

---

## Bus Management

### Get Assigned Buses
**GET** `/api/driver/assigned-buses`

Get all buses assigned to the driver.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "_id": "bus_id",
      "name": "Deluxe Bus",
      "vehicleNumber": "BA-1234",
      "from": "Kathmandu",
      "to": "Pokhara",
      "date": "2024-01-15",
      "time": "06:00 AM",
      "arrival": "02:00 PM",
      "price": 1500,
      "totalSeats": 40,
      "busType": "Deluxe"
    }
  ]
}
```

---

### Get Bus Details
**GET** `/api/driver/bus/:busId`

Get detailed information about an assigned bus.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "success": true,
  "data": {
    "_id": "bus_id",
    "name": "Deluxe Bus",
    "vehicleNumber": "BA-1234",
    "from": "Kathmandu",
    "to": "Pokhara",
    "date": "2024-01-15",
    "time": "06:00 AM",
    "arrival": "02:00 PM",
    "price": 1500,
    "totalSeats": 40,
    "filledSeats": 25,
    "bookedSeats": [1, 2, 3, ...],
    "routeId": { /* route details */ },
    "driverId": { /* driver details */ }
  }
}
```

**Note:** Driver can only view buses they are assigned to (checked via `assignedBusIds` array).

---

### Get Driver Dashboard
**GET** `/api/driver/dashboard`

Get driver dashboard with assigned buses, trip status, and statistics.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "success": true,
  "data": {
    "driver": { /* driver details */ },
    "assignedBuses": [ /* bus list */ ],
    "activeTrips": [ /* active trips */ ],
    "todayStats": {
      "tripsCompleted": 2,
      "passengersServed": 50
    }
  }
}
```

---

## Trip Management

### Get Trip Status
**GET** `/api/driver/trip-status`

Get current trip status for assigned buses.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `busId` (optional): Filter by bus ID

**Response:**
```json
{
  "success": true,
  "data": {
    "busId": "bus_id",
    "tripStatus": "in_transit",
    "currentLocation": {
      "latitude": 27.7172,
      "longitude": 85.3240
    },
    "startedAt": "2024-01-15T06:00:00Z",
    "estimatedArrival": "2024-01-15T14:00:00Z"
  }
}
```

---

### Mark Reached
**POST** `/api/driver/mark-reached`

Mark destination as reached.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "busId": "bus_id"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Destination marked as reached",
  "data": {
    "bus": { /* updated bus */ },
    "reachedAt": "2024-01-15T14:00:00Z"
  }
}
```

---

## Location Sharing

### Start Location Sharing
**POST** `/api/driver/location/start`

Start GPS location sharing for a bus.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "busId": "bus_id"
}
```

**Requirements:**
- Driver must be `ACTIVE` status
- Driver must be assigned to the bus
- Bus must be active

**Response:**
```json
{
  "success": true,
  "message": "Location sharing started",
  "data": {
    "isLocationSharing": true,
    "busId": "bus_id"
  }
}
```

---

### Stop Location Sharing
**POST** `/api/driver/location/stop`

Stop GPS location sharing.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "busId": "bus_id"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Location sharing stopped",
  "data": {
    "isLocationSharing": false
  }
}
```

---

## Request Management

### Get Pending Requests
**GET** `/api/driver/pending-requests`

Get pending bus assignment requests.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "_id": "request_id",
      "busId": { /* bus details */ },
      "requestedBy": { /* owner/counter details */ },
      "status": "PENDING",
      "createdAt": "2024-01-15T10:00:00Z"
    }
  ]
}
```

---

### Accept Request
**POST** `/api/driver/accept-request/:requestId`

Accept a bus assignment request.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "success": true,
  "message": "Request accepted successfully",
  "data": {
    "driver": { /* updated driver */ },
    "bus": { /* bus details */ }
  }
}
```

---

### Reject Request
**POST** `/api/driver/reject-request/:requestId`

Reject a bus assignment request.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "success": true,
  "message": "Request rejected successfully"
}
```

---

## Driver Invitation (Owner/Counter/Admin)

### Invite Driver
**POST** `/api/driver/invite`

Owner/Counter/Admin invites a driver (sends OTP).

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "phoneNumber": "9876543210",
  "name": "Driver Name",
  "licenseNumber": "LIC123456",
  "email": "driver@example.com",
  "busId": "bus_id" // Optional
}
```

**Response:**
```json
{
  "success": true,
  "message": "Driver invitation sent successfully",
  "data": {
    "driverId": "driver_id",
    "phoneNumber": "9876543210",
    "message": "OTP sent to driver"
  }
}
```

**Note:** This endpoint is for Owner/Counter/Admin use. Regular drivers use registration/login endpoints.

---

## Complete Driver Flow

### Scenario 1: Driver Registration with OTP

1. **Owner adds driver:**
   ```
   POST /api/owner/staff/driver
   Body: { name, email, phoneNumber, licenseNumber, licensePhoto, driverPhoto }
   → OTP generated and sent to email
   ```

2. **Driver receives OTP email:**
   - Email contains: OTP code, owner name, instructions

3. **Driver registers:**
   ```
   POST /api/driver/register
   Body: { name, email, phoneNumber, password, licenseNumber, hasOTP: true, otp: "123456", licensePhoto, driverPhoto }
   → Driver registered and associated with owner
   ```

### Scenario 2: Driver Login with OTP

1. **Driver already registered but not associated:**
   ```
   POST /api/driver/login
   Body: { email, password, hasOTP: true, otp: "123456" }
   → Login successful and associated with owner
   ```

### Scenario 3: Driver Registration without OTP

1. **Driver registers independently:**
   ```
   POST /api/driver/register
   Body: { name, email, phoneNumber, password, licenseNumber, licensePhoto, driverPhoto }
   → Driver registered but not associated with any owner
   ```

2. **Later, owner invites driver:**
   ```
   POST /api/owner/staff/driver
   Body: { email, ... }
   → OTP sent to driver
   ```

3. **Driver logs in with OTP:**
   ```
   POST /api/driver/login
   Body: { email, password, hasOTP: true, otp: "123456" }
   → Associated with owner
   ```

---

## Driver Status Values

- `INVITED`: Driver invited but not yet registered
- `REGISTERED`: Driver registered and active
- `ACTIVE`: Driver is active and can share location
- `INACTIVE`: Driver is inactive

---

## Error Responses

**401 Unauthorized:**
```json
{
  "success": false,
  "message": "Not authorized, token failed"
}
```

**400 Bad Request:**
```json
{
  "success": false,
  "message": "Invalid OTP" // or other validation error
}
```

**403 Forbidden:**
```json
{
  "success": false,
  "message": "Driver account not verified"
}
```

---

## Important Notes

1. **OTP Expiration:** OTP expires in 24 hours
2. **OTP Single Use:** OTP is cleared after successful association
3. **Email Matching:** When using OTP, email must match the email that received the OTP
4. **Owner Association:** Driver can be associated with only one owner at a time
5. **Bus Assignment:** Drivers are assigned to buses via `assignedBusIds` array
6. **Location Sharing:** Only ACTIVE drivers assigned to active buses can share location

---

**Last Updated:** 2024-01-15  
**Version:** 1.0.0
