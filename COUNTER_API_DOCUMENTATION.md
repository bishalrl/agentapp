# Counter API Documentation - Complete Reference

## Overview
This document contains all API endpoints available for Counter users in the NeeloSewa system. Counters can manage bookings, buses, drivers, routes, schedules, wallet, notifications, and more.

**Base URLs:**
- New APIs: `/api/counter/*`
- Legacy APIs: `/api/bus-agent/*` (backward compatible)

**Authentication:**
All protected endpoints require JWT token in header:
```
Authorization: Bearer <token>
```

---

## Table of Contents
1. [Authentication & Registration](#1-authentication--registration)
2. [Profile Management](#2-profile-management)
3. [Dashboard](#3-dashboard)
4. [Bus Management](#4-bus-management)
5. [Booking Management](#5-booking-management)
6. [Driver Management](#6-driver-management)
7. [Route Management](#7-route-management)
8. [Schedule Management](#8-schedule-management)
9. [Wallet Management](#9-wallet-management)
10. [Notifications](#10-notifications)
11. [Sales & Reports](#11-sales--reports)
12. [Offline Mode](#12-offline-mode)
13. [Audit Logs](#13-audit-logs)

---

## 1. Authentication & Registration

### 1.1 Register Counter
**Endpoint:** `POST /api/auth/register-bus-agent`  
**Access:** Public  
**Description:** Register a new counter with document uploads

**Request Body (multipart/form-data):**
```json
{
  "agencyName": "string (required)",
  "ownerName": "string (required)",
  "panVatNumber": "string (optional)",
  "address": "string (required)",
  "districtProvince": "string (required)",
  "primaryContact": "string (required)",
  "alternateContact": "string (optional)",
  "email": "string (required, unique)",
  "whatsappViber": "string (optional)",
  "officeLocation": "string (required)",
  "officeOpenTime": "string (required)",
  "officeCloseTime": "string (required)",
  "numberOfEmployees": "number (required)",
  "hasDeviceAccess": "boolean (required)",
  "hasInternetAccess": "boolean (required)",
  "preferredBookingMethod": "string (required)",
  "password": "string (required, min 6 chars)"
}
```

**Files (multipart/form-data):**
- `citizenshipFile`: File (required) - Citizenship document
- `photoFile`: File (required) - Passport photo
- `panFile`: File (optional) - PAN/VAT document
- `registrationFile`: File (optional) - Registration document

**Response (201):**
```json
{
  "message": "Registration successful! We will review your documents and contact you by email after verification."
}
```

**Error Responses:**
- `400`: Missing required fields or files
- `400`: Email already registered
- `500`: Server error

---

### 1.2 Login Counter
**Endpoint:** `POST /api/auth/login-bus-agent`  
**Access:** Public  
**Description:** Authenticate counter and get JWT token

**Request Body:**
```json
{
  "email": "string (required)",
  "password": "string (required)"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Counter login successful",
  "token": "jwt_token_string",
  "mustChangePassword": true,
  "data": {
    "counter": {
      "_id": "counter_id",
      "agencyName": "string",
      "email": "string",
      "ownerName": "string",
      "panVatNumber": "string",
      "address": "string",
      "districtProvince": "string",
      "primaryContact": "string",
      "alternateContact": "string",
      "whatsappViber": "string",
      "officeLocation": "string",
      "officeOpenTime": "string",
      "officeCloseTime": "string",
      "numberOfEmployees": 0,
      "hasDeviceAccess": true,
      "hasInternetAccess": true,
      "preferredBookingMethod": "string",
      "citizenshipFile": "string",
      "photoFile": "string",
      "panFile": "string",
      "registrationFile": "string",
      "walletBalance": 0
    }
  }
}
```

**Error Responses:**
- `400`: Invalid credentials
- `403`: Account not verified yet
- `500`: Server error

---

### 1.3 Change Password
**Endpoint:** `POST /api/auth/bus-agent-change-password`  
**Access:** Private (Counter)  
**Description:** Change password after first login or update password

**Request Body:**
```json
{
  "password": "string (required, min 6 chars)"
}
```

**Response (200):**
```json
{
  "message": "Password changed successfully"
}
```

**Error Responses:**
- `400`: Password too short
- `404`: Counter not found
- `500`: Server error

---

### 1.4 Get Counter Profile (Auth)
**Endpoint:** `GET /api/auth/me-bus-agent`  
**Access:** Private (Counter)  
**Description:** Get current authenticated counter profile

**Response (200):**
```json
{
  "_id": "counter_id",
  "agencyName": "string",
  "email": "string",
  "ownerName": "string",
  "walletBalance": 0,
  "isVerified": true,
  "mustChangePassword": false,
  // ... all counter fields
}
```

---

## 2. Profile Management

### 2.1 Get Profile
**Endpoint:** `GET /api/counter/profile`  
**Access:** Private (Counter)  
**Description:** Get counter profile information

**Response (200):**
```json
{
  "success": true,
  "data": {
    "counter": {
      "_id": "counter_id",
      "agencyName": "string",
      "ownerName": "string",
      "email": "string",
      "walletBalance": 0,
      "avatarUrl": "string",
      // ... all profile fields
    }
  }
}
```

---

### 2.2 Update Profile
**Endpoint:** `PUT /api/counter/profile`  
**Access:** Private (Counter)  
**Description:** Update counter profile information

**Request Body (multipart/form-data):**
```json
{
  "agencyName": "string (optional)",
  "ownerName": "string (optional)",
  "panVatNumber": "string (optional)",
  "address": "string (optional)",
  "districtProvince": "string (optional)",
  "primaryContact": "string (optional)",
  "alternateContact": "string (optional)",
  "whatsappViber": "string (optional)",
  "officeLocation": "string (optional)",
  "officeOpenTime": "string (optional)",
  "officeCloseTime": "string (optional)",
  "numberOfEmployees": "number (optional)",
  "hasDeviceAccess": "boolean (optional)",
  "hasInternetAccess": "boolean (optional)",
  "preferredBookingMethod": "string (optional)"
}
```

**Files:**
- `avatar`: File (optional) - Profile picture

**Response (200):**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "counter": {
      // Updated counter object
    }
  }
}
```

---

## 3. Dashboard

### 3.1 Get Dashboard
**Endpoint:** `GET /api/counter/dashboard`  
**Access:** Private (Counter)  
**Description:** Get dashboard data with assigned buses, today's stats, and performance metrics

**Response (200):**
```json
{
  "success": true,
  "data": {
    "assignedBuses": [
      {
        "busId": "bus_id",
        "bus": {
          "name": "string",
          "from": "string",
          "to": "string",
          "date": "YYYY-MM-DD",
          "time": "HH:MM",
          "price": 0,
          "totalSeats": 0,
          "busType": "string",
          "vehicleNumber": "string"
        },
        "allowedSeats": [1, 2, 3],
        "commissionEarned": 0,
        "totalBookings": 0
      }
    ],
    "todayStats": {
      "totalBookings": 0,
      "totalSales": 0,
      "cashSales": 0,
      "onlineSales": 0
    },
    "busesByDate": {
      "YYYY-MM-DD": {
        "route-key": {
          "buses": [],
          "totalSeats": 0,
          "availableSeats": 0
        }
      }
    }
  }
}
```

---

## 4. Bus Management

### 4.1 Get Assigned Buses
**Endpoint:** `GET /api/counter/buses`  
**Access:** Private (Counter)  
**Description:** Get all buses assigned to counter by admin/owner

**Query Parameters:**
- `date` (optional): Filter by date (YYYY-MM-DD)
- `from` (optional): Filter by origin
- `to` (optional): Filter by destination

**Response (200):**
```json
{
  "success": true,
  "data": {
    "buses": [
      {
        "busId": "bus_id",
        "bus": {
          "_id": "bus_id",
          "name": "string",
          "from": "string",
          "to": "string",
          "date": "YYYY-MM-DD",
          "time": "HH:MM",
          "arrival": "HH:MM",
          "price": 0,
          "totalSeats": 0,
          "filledSeats": 0,
          "availableSeats": 0,
          "busType": "string",
          "amenities": ["string"],
          "vehicleNumber": "string"
        },
        "allowedSeats": [1, 2, 3],
        "commissionEarned": 0,
        "totalBookings": 0
      }
    ]
  }
}
```

---

### 4.2 Get Bus Details
**Endpoint:** `GET /api/counter/buses/:busId`  
**Access:** Private (Counter)  
**Description:** Get detailed information about a specific assigned bus

**Response (200):**
```json
{
  "success": true,
  "data": {
    "bus": {
      // Complete bus object with all details
    },
    "access": {
      "allowedSeats": [1, 2, 3],
      "commissionEarned": 0,
      "totalBookings": 0
    }
  }
}
```

---

### 4.3 Create Own Bus
**Endpoint:** `POST /api/counter/buses`  
**Access:** Private (Counter)  
**Description:** Create a new bus owned by counter

**Request Body (multipart/form-data):**
```json
{
  "name": "string (required)",
  "from": "string (required)",
  "to": "string (required)",
  "date": "YYYY-MM-DD (required)",
  "time": "HH:MM (required)",
  "arrival": "HH:MM (required)",
  "price": "number (required)",
  "totalSeats": "number (required, 33 or 45)",
  "busType": "string (required)",
  "amenities": "string (comma-separated, optional)",
  "vehicleNumber": "string (required)",
  "driverContact": "string (optional)",
  "driverId": "string (optional)",
  "commissionRate": "number (optional)"
}
```

**Files:**
- `mainImage`: File (optional) - Main bus image
- `galleryImages`: File[] (optional, max 10) - Gallery images

**Response (201):**
```json
{
  "success": true,
  "message": "Bus created successfully",
  "data": {
    "bus": {
      // Created bus object
    }
  }
}
```

---

### 4.4 Get My Buses
**Endpoint:** `GET /api/counter/buses/my-buses`  
**Access:** Private (Counter)  
**Description:** Get all buses created by counter

**Query Parameters:**
- `date` (optional): Filter by date
- `from` (optional): Filter by origin
- `to` (optional): Filter by destination

**Response (200):**
```json
{
  "success": true,
  "data": {
    "buses": [
      {
        // Bus objects created by counter
      }
    ]
  }
}
```

---

### 4.5 Get My Bus by ID
**Endpoint:** `GET /api/counter/buses/my-buses/:busId`  
**Access:** Private (Counter)  
**Description:** Get details of a specific bus created by counter

**Response (200):**
```json
{
  "success": true,
  "data": {
    "bus": {
      // Complete bus object
    }
  }
}
```

---

### 4.6 Update My Bus
**Endpoint:** `PUT /api/counter/buses/my-buses/:busId`  
**Access:** Private (Counter)  
**Description:** Update a bus created by counter

**Request Body (multipart/form-data):**
```json
{
  "name": "string (optional)",
  "from": "string (optional)",
  "to": "string (optional)",
  "date": "YYYY-MM-DD (optional)",
  "time": "HH:MM (optional)",
  "arrival": "HH:MM (optional)",
  "price": "number (optional)",
  "totalSeats": "number (optional)",
  "busType": "string (optional)",
  "amenities": "string (optional)",
  "vehicleNumber": "string (optional)",
  "driverContact": "string (optional)",
  "driverId": "string (optional)"
}
```

**Files:**
- `mainImage`: File (optional)
- `galleryImages`: File[] (optional)

**Response (200):**
```json
{
  "success": true,
  "message": "Bus updated successfully",
  "data": {
    "bus": {
      // Updated bus object
    }
  }
}
```

---

### 4.7 Delete My Bus
**Endpoint:** `DELETE /api/counter/buses/my-buses/:busId`  
**Access:** Private (Counter)  
**Description:** Delete a bus created by counter

**Response (200):**
```json
{
  "success": true,
  "message": "Bus deleted successfully"
}
```

**Error Responses:**
- `403`: Bus not owned by counter
- `404`: Bus not found

---

## 5. Booking Management

### 5.1 Create Booking
**Endpoint:** `POST /api/counter/bookings`  
**Access:** Private (Counter)  
**Description:** Create a new booking for one or more seats

**Request Body:**
```json
{
  "busId": "string (required)",
  "seatNumbers": [1, 2, 3],
  "passengerName": "string (required)",
  "passengerEmail": "string (required)",
  "passengerPhone": "string (required)",
  "contactNumber": "string (required)",
  "paymentMethod": "cash|online|wallet (required)",
  "price": "number (required)",
  "passengerAge": "number (optional)",
  "passengerGender": "male|female|other (optional)",
  "specialRequests": "string (optional)"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Booking created successfully",
  "data": {
    "bookings": [
      {
        "_id": "booking_id",
        "ticketNumber": "string",
        "busId": "bus_id",
        "seatNumber": 1,
        "passengerName": "string",
        "passengerEmail": "string",
        "passengerPhone": "string",
        "price": 0,
        "status": "Confirmed",
        "paymentMethod": "cash",
        "createdAt": "ISO date"
      }
    ],
    "totalPrice": 0,
    "ticketNumber": "string"
  }
}
```

**Features:**
- Seat locking during booking
- Commission calculation
- Admin wallet crediting
- Email notification with PDF ticket
- Real-time Socket.IO updates

---

### 5.2 Get Bookings
**Endpoint:** `GET /api/counter/bookings`  
**Access:** Private (Counter)  
**Description:** Get all bookings made by counter

**Query Parameters:**
- `status` (optional): Filter by status (Confirmed, Cancelled, Completed)
- `date` (optional): Filter by booking date
- `busId` (optional): Filter by bus
- `ticketNumber` (optional): Filter by ticket number
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 10)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "bookings": [
      {
        "_id": "booking_id",
        "ticketNumber": "string",
        "busId": "bus_id",
        "bus": {
          "name": "string",
          "from": "string",
          "to": "string",
          "date": "YYYY-MM-DD",
          "time": "HH:MM"
        },
        "seatNumber": 1,
        "passengerName": "string",
        "passengerEmail": "string",
        "passengerPhone": "string",
        "price": 0,
        "status": "Confirmed",
        "paymentMethod": "cash",
        "createdAt": "ISO date"
      }
    ],
    "pagination": {
      "currentPage": 1,
      "totalPages": 1,
      "totalItems": 10,
      "itemsPerPage": 10
    }
  }
}
```

---

### 5.3 Get Booking Details
**Endpoint:** `GET /api/counter/bookings/:bookingId`  
**Access:** Private (Counter)  
**Description:** Get detailed information about a specific booking

**Response (200):**
```json
{
  "success": true,
  "data": {
    "booking": {
      // Complete booking object with populated bus details
    }
  }
}
```

---

### 5.4 Cancel Booking
**Endpoint:** `PUT /api/counter/bookings/:bookingId/cancel`  
**Access:** Private (Counter)  
**Description:** Cancel a single booking

**Request Body:**
```json
{
  "reason": "string (optional)"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Booking cancelled successfully",
  "data": {
    "booking": {
      // Updated booking object
    },
    "refund": 0
  }
}
```

**Features:**
- Refund processing (time-based policy)
- Commission reversal
- Admin wallet adjustment
- Email notification
- Real-time updates

---

### 5.5 Cancel Multiple Bookings
**Endpoint:** `PUT /api/counter/bookings/cancel-multiple`  
**Access:** Private (Counter)  
**Description:** Cancel multiple bookings with same ticket number (bulk cancel)

**Request Body:**
```json
{
  "bookingIds": ["booking_id1", "booking_id2", "booking_id3"]
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "3 seat(s) cancelled successfully for ticket TICKET-123",
  "data": {
    "cancelledBookings": 3,
    "ticketNumber": "TICKET-123"
  }
}
```

**Features:**
- Bulk cancellation
- Refund processing
- Commission reversal
- Email notification to passenger
- Real-time updates

---

### 5.6 Update Booking Status
**Endpoint:** `PATCH /api/counter/bookings/:id/status`  
**Access:** Private (Counter)  
**Description:** Update booking status (e.g., Confirmed → Completed)

**Request Body:**
```json
{
  "status": "Confirmed|Cancelled|Completed (required)"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Booking status updated",
  "data": {
    "booking": {
      // Updated booking object
    }
  }
}
```

---

## 6. Driver Management

### 6.1 Invite Driver
**Endpoint:** `POST /api/counter/drivers/invite`  
**Access:** Private (Counter)  
**Description:** Invite a new driver with OTP

**Request Body:**
```json
{
  "name": "string (required)",
  "phoneNumber": "string (required)",
  "email": "string (optional)",
  "licenseNumber": "string (required)",
  "licenseExpiry": "YYYY-MM-DD (required)",
  "address": "string (optional)",
  "busId": "string (optional)" // Auto-assign if provided
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Driver invited successfully. OTP sent to phone number.",
  "data": {
    "driver": {
      "_id": "driver_id",
      "name": "string",
      "phoneNumber": "string",
      "otp": "string",
      "otpExpiry": "ISO date",
      "invitedBy": "counter_id",
      "invitedByType": "BusAgent"
    }
  }
}
```

---

### 6.2 Get My Drivers
**Endpoint:** `GET /api/counter/drivers`  
**Access:** Private (Counter)  
**Description:** Get all drivers invited by counter

**Query Parameters:**
- `status` (optional): Filter by status (pending, verified, active)
- `busId` (optional): Filter by assigned bus

**Response (200):**
```json
{
  "success": true,
  "data": {
    "drivers": [
      {
        "_id": "driver_id",
        "name": "string",
        "phoneNumber": "string",
        "email": "string",
        "licenseNumber": "string",
        "status": "verified",
        "assignedBusId": "bus_id",
        "assignedBusIds": ["bus_id"],
        "invitedBy": "counter_id",
        "invitedByType": "BusAgent"
      }
    ]
  }
}
```

---

### 6.3 Get Driver by ID
**Endpoint:** `GET /api/counter/drivers/:driverId`  
**Access:** Private (Counter)  
**Description:** Get detailed information about a specific driver

**Response (200):**
```json
{
  "success": true,
  "data": {
    "driver": {
      // Complete driver object
    }
  }
}
```

---

### 6.4 Assign Driver to Bus
**Endpoint:** `PUT /api/counter/drivers/:driverId/assign-bus`  
**Access:** Private (Counter)  
**Description:** Assign a driver to a bus

**Request Body:**
```json
{
  "busId": "string (required)"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Driver assigned to bus successfully",
  "data": {
    "driver": {
      // Updated driver object
    },
    "bus": {
      // Bus object
    }
  }
}
```

**Error Responses:**
- `403`: Driver not invited by counter or bus not owned by counter

---

### 6.5 Update Driver
**Endpoint:** `PUT /api/counter/drivers/:driverId`  
**Access:** Private (Counter)  
**Description:** Update driver information

**Request Body:**
```json
{
  "name": "string (optional)",
  "email": "string (optional)",
  "licenseNumber": "string (optional)",
  "licenseExpiry": "YYYY-MM-DD (optional)",
  "address": "string (optional)"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Driver updated successfully",
  "data": {
    "driver": {
      // Updated driver object
    }
  }
}
```

---

### 6.6 Delete Driver
**Endpoint:** `DELETE /api/counter/drivers/:driverId`  
**Access:** Private (Counter)  
**Description:** Delete a driver (only if invited by counter)

**Response (200):**
```json
{
  "success": true,
  "message": "Driver deleted successfully"
}
```

**Error Responses:**
- `403`: Driver not invited by counter

---

## 7. Route Management

### 7.1 Create Route
**Endpoint:** `POST /api/counter/routes`  
**Access:** Private (Counter)  
**Description:** Create a new route with stops

**Request Body:**
```json
{
  "name": "string (required)",
  "from": "string (required)",
  "to": "string (required)",
  "distance": "number (optional)",
  "duration": "number (optional, in minutes)",
  "stops": [
    {
      "name": "string (required)",
      "order": "number (required)",
      "distanceFromOrigin": "number (optional)",
      "estimatedTime": "string (optional)"
    }
  ]
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Route created successfully",
  "data": {
    "route": {
      "_id": "route_id",
      "name": "string",
      "from": "string",
      "to": "string",
      "stops": [],
      "createdBy": "counter_id",
      "createdByType": "BusAgent"
    }
  }
}
```

---

### 7.2 Get My Routes
**Endpoint:** `GET /api/counter/routes`  
**Access:** Private (Counter)  
**Description:** Get all routes created by counter

**Query Parameters:**
- `from` (optional): Filter by origin
- `to` (optional): Filter by destination

**Response (200):**
```json
{
  "success": true,
  "data": {
    "routes": [
      {
        "_id": "route_id",
        "name": "string",
        "from": "string",
        "to": "string",
        "stops": [],
        "createdBy": "counter_id",
        "createdByType": "BusAgent"
      }
    ]
  }
}
```

---

### 7.3 Get Route by ID
**Endpoint:** `GET /api/counter/routes/:routeId`  
**Access:** Private (Counter)  
**Description:** Get detailed information about a specific route

**Response (200):**
```json
{
  "success": true,
  "data": {
    "route": {
      // Complete route object
    }
  }
}
```

---

### 7.4 Update Route
**Endpoint:** `PUT /api/counter/routes/:routeId`  
**Access:** Private (Counter)  
**Description:** Update a route created by counter

**Request Body:**
```json
{
  "name": "string (optional)",
  "from": "string (optional)",
  "to": "string (optional)",
  "distance": "number (optional)",
  "duration": "number (optional)",
  "stops": [] // Optional
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Route updated successfully",
  "data": {
    "route": {
      // Updated route object
    }
  }
}
```

---

### 7.5 Delete Route
**Endpoint:** `DELETE /api/counter/routes/:routeId`  
**Access:** Private (Counter)  
**Description:** Delete a route created by counter

**Response (200):**
```json
{
  "success": true,
  "message": "Route deleted successfully"
}
```

**Error Responses:**
- `403`: Route not owned by counter

---

## 8. Schedule Management

### 8.1 Create Schedule
**Endpoint:** `POST /api/counter/schedules`  
**Access:** Private (Counter)  
**Description:** Create a new schedule

**Request Body:**
```json
{
  "routeId": "string (required)",
  "busId": "string (optional)",
  "departureTime": "HH:MM (required)",
  "arrivalTime": "HH:MM (required)",
  "daysOfWeek": ["monday", "tuesday", "wednesday"],
  "isActive": "boolean (optional, default: true)"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Schedule created successfully",
  "data": {
    "schedule": {
      // Schedule object
    }
  }
}
```

---

### 8.2 Get Schedules
**Endpoint:** `GET /api/counter/schedules`  
**Access:** Private (Counter)  
**Description:** Get all schedules created by counter

**Query Parameters:**
- `routeId` (optional): Filter by route
- `busId` (optional): Filter by bus
- `isActive` (optional): Filter by active status

**Response (200):**
```json
{
  "success": true,
  "data": {
    "schedules": [
      {
        // Schedule objects
      }
    ]
  }
}
```

---

### 8.3 Get Schedule by ID
**Endpoint:** `GET /api/counter/schedules/:scheduleId`  
**Access:** Private (Counter)  
**Description:** Get detailed information about a specific schedule

**Response (200):**
```json
{
  "success": true,
  "data": {
    "schedule": {
      // Complete schedule object
    }
  }
}
```

---

### 8.4 Update Schedule
**Endpoint:** `PUT /api/counter/schedules/:scheduleId`  
**Access:** Private (Counter)  
**Description:** Update a schedule created by counter

**Request Body:**
```json
{
  "departureTime": "HH:MM (optional)",
  "arrivalTime": "HH:MM (optional)",
  "daysOfWeek": [] (optional),
  "isActive": "boolean (optional)"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Schedule updated successfully",
  "data": {
    "schedule": {
      // Updated schedule object
    }
  }
}
```

---

### 8.5 Delete Schedule
**Endpoint:** `DELETE /api/counter/schedules/:scheduleId`  
**Access:** Private (Counter)  
**Description:** Delete a schedule created by counter

**Response (200):**
```json
{
  "success": true,
  "message": "Schedule deleted successfully"
}
```

---

## 9. Wallet Management

### 9.1 Add Money to Wallet
**Endpoint:** `POST /api/counter/wallet/add`  
**Access:** Private (Counter)  
**Description:** Add money to counter wallet

**Request Body:**
```json
{
  "amount": "number (required, > 0)",
  "description": "string (optional)"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Money added to wallet successfully",
  "data": {
    "counter": {
      "walletBalance": 0
    },
    "transaction": {
      "_id": "transaction_id",
      "type": "credit",
      "amount": 0,
      "description": "string",
      "createdAt": "ISO date"
    }
  }
}
```

---

### 9.2 Get Transactions
**Endpoint:** `GET /api/counter/wallet/transactions`  
**Access:** Private (Counter)  
**Description:** Get wallet transaction history

**Query Parameters:**
- `type` (optional): Filter by type (credit, debit)
- `startDate` (optional): Filter from date
- `endDate` (optional): Filter to date
- `page` (optional): Page number
- `limit` (optional): Items per page

**Response (200):**
```json
{
  "success": true,
  "data": {
    "transactions": [
      {
        "_id": "transaction_id",
        "type": "credit|debit",
        "amount": 0,
        "description": "string",
        "createdAt": "ISO date"
      }
    ],
    "pagination": {
      "currentPage": 1,
      "totalPages": 1,
      "totalItems": 10
    }
  }
}
```

---

## 10. Notifications

### 10.1 Get Notifications
**Endpoint:** `GET /api/counter/notifications`  
**Access:** Private (Counter)  
**Description:** Get all notifications for counter

**Query Parameters:**
- `read` (optional): Filter by read status (true/false)
- `type` (optional): Filter by notification type
- `page` (optional): Page number
- `limit` (optional): Items per page

**Response (200):**
```json
{
  "success": true,
  "data": {
    "notifications": [
      {
        "_id": "notification_id",
        "type": "booking| cancellation|system",
        "message": "string",
        "read": false,
        "createdAt": "ISO date"
      }
    ],
    "unreadCount": 5
  }
}
```

---

### 10.2 Mark Notifications as Read
**Endpoint:** `POST /api/counter/notifications/mark-read`  
**Access:** Private (Counter)  
**Description:** Mark specific notifications as read

**Request Body:**
```json
{
  "notificationIds": ["id1", "id2", "id3"]
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Notifications marked as read",
  "data": {
    "updatedCount": 3
  }
}
```

---

### 10.3 Mark All Notifications as Read
**Endpoint:** `POST /api/counter/notifications/mark-all-read`  
**Access:** Private (Counter)  
**Description:** Mark all notifications as read

**Response (200):**
```json
{
  "success": true,
  "message": "All notifications marked as read",
  "data": {
    "updatedCount": 10
  }
}
```

---

### 10.4 Delete Notification
**Endpoint:** `DELETE /api/counter/notifications/:id`  
**Access:** Private (Counter)  
**Description:** Delete a specific notification

**Response (200):**
```json
{
  "success": true,
  "message": "Notification deleted successfully"
}
```

---

### 10.5 Delete All Notifications
**Endpoint:** `DELETE /api/counter/notifications`  
**Access:** Private (Counter)  
**Description:** Delete all notifications

**Response (200):**
```json
{
  "success": true,
  "message": "All notifications deleted successfully",
  "data": {
    "deletedCount": 10
  }
}
```

---

## 11. Sales & Reports

### 11.1 Get Sales Summary
**Endpoint:** `GET /api/counter/sales/summary`  
**Access:** Private (Counter)  
**Description:** Get sales summary with filters

**Query Parameters:**
- `startDate` (optional): Start date (YYYY-MM-DD)
- `endDate` (optional): End date (YYYY-MM-DD)
- `busId` (optional): Filter by bus
- `paymentMethod` (optional): Filter by payment method (cash, online, wallet)
- `groupBy` (optional): Group by (date, bus, paymentMethod)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "summary": {
      "totalSales": 0,
      "totalBookings": 0,
      "cashSales": 0,
      "onlineSales": 0,
      "walletSales": 0,
      "totalCommission": 0,
      "totalRefunds": 0
    },
    "groupedData": [
      {
        "key": "group_key",
        "sales": 0,
        "bookings": 0
      }
    ],
    "dateRange": {
      "startDate": "YYYY-MM-DD",
      "endDate": "YYYY-MM-DD"
    }
  }
}
```

---

## 12. Offline Mode

### 12.1 Get Offline Queue
**Endpoint:** `GET /api/counter/offline/queue`  
**Access:** Private (Counter)  
**Description:** Get all bookings in offline queue

**Response (200):**
```json
{
  "success": true,
  "data": {
    "queue": [
      {
        "_id": "queue_id",
        "bookingData": {},
        "status": "pending|synced|failed",
        "createdAt": "ISO date"
      }
    ],
    "totalPending": 5
  }
}
```

---

### 12.2 Add to Offline Queue
**Endpoint:** `POST /api/counter/offline/queue`  
**Access:** Private (Counter)  
**Description:** Add booking to offline queue when offline

**Request Body:**
```json
{
  "bookingData": {
    // Complete booking data
  }
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Booking added to offline queue",
  "data": {
    "queueItem": {
      // Queue item object
    }
  }
}
```

---

### 12.3 Sync Offline Bookings
**Endpoint:** `POST /api/counter/offline/sync`  
**Access:** Private (Counter)  
**Description:** Sync offline bookings when connection restored

**Response (200):**
```json
{
  "success": true,
  "message": "Offline bookings synced",
  "data": {
    "synced": 5,
    "failed": 0,
    "conflicts": []
  }
}
```

---

## 13. Audit Logs

### 13.1 Get Audit Logs
**Endpoint:** `GET /api/counter/audit-logs`  
**Access:** Private (Counter)  
**Description:** Get audit logs of all counter actions

**Query Parameters:**
- `action` (optional): Filter by action type
- `startDate` (optional): Filter from date
- `endDate` (optional): Filter to date
- `page` (optional): Page number
- `limit` (optional): Items per page

**Response (200):**
```json
{
  "success": true,
  "data": {
    "logs": [
      {
        "_id": "log_id",
        "action": "booking_created|bus_created|driver_invited",
        "details": {},
        "busId": "bus_id",
        "bookingId": "booking_id",
        "ipAddress": "string",
        "userAgent": "string",
        "createdAt": "ISO date"
      }
    ],
    "pagination": {
      "currentPage": 1,
      "totalPages": 1,
      "totalItems": 100
    }
  }
}
```

---

## Legacy Endpoints (Backward Compatible)

All legacy endpoints under `/api/bus-agent/*` are still available and work exactly the same:

- `GET /api/bus-agent/profile`
- `PUT /api/bus-agent/profile`
- `GET /api/bus-agent/bookings`
- `POST /api/bus-agent/bookings`
- `PUT /api/bus-agent/bookings/:bookingId/cancel`
- `PUT /api/bus-agent/bookings/cancel-multiple`
- `GET /api/bus-agent/buses`
- `GET /api/bus-agent/buses/:id`
- `GET /api/bus-agent/notifications`
- `POST /api/bus-agent/wallet/add`
- `GET /api/bus-agent/wallet/transactions`

---

## Error Responses

All endpoints may return these common error responses:

**400 Bad Request:**
```json
{
  "success": false,
  "message": "Error message"
}
```

**401 Unauthorized:**
```json
{
  "success": false,
  "message": "Not authorized, no token"
}
```

**403 Forbidden:**
```json
{
  "success": false,
  "message": "Access denied"
}
```

**404 Not Found:**
```json
{
  "success": false,
  "message": "Resource not found"
}
```

**500 Internal Server Error:**
```json
{
  "success": false,
  "message": "Server error"
}
```

---

## Notes

1. **Authentication**: All protected endpoints require JWT token in `Authorization: Bearer <token>` header
2. **File Uploads**: Use `multipart/form-data` for endpoints that accept files
3. **Pagination**: Most list endpoints support pagination with `page` and `limit` query parameters
4. **Real-time Updates**: Booking operations emit Socket.IO events for real-time updates
5. **Commission**: Automatically calculated and credited to admin wallet on bookings
6. **Refunds**: Time-based refund policy applied automatically on cancellations
7. **Email Notifications**: Sent automatically for bookings and cancellations with PDF tickets
8. **Audit Logging**: All counter actions are logged for audit trail

---

*Last Updated: 2026-01-11*  
*API Version: 1.0*
