# Counter & Driver API Quick Reference

Quick reference table for all Counter and Driver API endpoints.

---

## Counter APIs

**Base URL:** `/api/counter`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| **Authentication** |
| POST | `/api/auth/register-bus-agent` | Register counter | No |
| POST | `/api/auth/login-bus-agent` | Login counter | No |
| POST | `/api/auth/forgot-password-counter` | Forgot password | No |
| POST | `/api/auth/reset-password-counter` | Reset password | No |
| **Profile** |
| GET | `/profile` | Get profile | Yes |
| PUT | `/profile` | Update profile | Yes |
| **Dashboard** |
| GET | `/dashboard` | Get dashboard | Yes |
| **Bus Management** |
| GET | `/buses` | Get assigned buses | Yes |
| GET | `/buses/:busId` | Get bus details | Yes |
| GET | `/buses/my-buses` | Get my buses (legacy) | Yes |
| GET | `/buses/my-buses/:busId` | Get my bus by ID | Yes |
| PUT | `/buses/my-buses/:busId` | Update my bus | Yes |
| DELETE | `/buses/my-buses/:busId` | Delete my bus | Yes |
| **Counter Requests** |
| POST | `/request-bus-access` | Request bus access | Yes |
| GET | `/requests` | Get my requests | Yes |
| **Bookings** |
| POST | `/bookings` | Create booking | Yes |
| GET | `/bookings` | Get bookings | Yes |
| GET | `/bookings/:bookingId` | Get booking details | Yes |
| PUT | `/bookings/:bookingId/cancel` | Cancel booking | Yes |
| PATCH | `/bookings/:id/status` | Update booking status | Yes |
| PUT | `/bookings/cancel-multiple` | Cancel multiple bookings | Yes |
| **Sales & Reports** |
| GET | `/sales/summary` | Get sales summary | Yes |
| **Offline Mode** |
| GET | `/offline/queue` | Get offline queue | Yes |
| POST | `/offline/queue` | Add to offline queue | Yes |
| POST | `/offline/sync` | Sync offline bookings | Yes |
| **Wallet** |
| POST | `/wallet/add` | Add money to wallet | Yes |
| GET | `/wallet/transactions` | Get transactions | Yes |
| **Notifications** |
| GET | `/notifications` | Get notifications | Yes |
| POST | `/notifications/mark-read` | Mark as read | Yes |
| POST | `/notifications/mark-all-read` | Mark all as read | Yes |
| DELETE | `/notifications/:id` | Delete notification | Yes |
| DELETE | `/notifications` | Delete all notifications | Yes |
| **Routes** |
| POST | `/routes` | Create route | Yes |
| GET | `/routes` | Get my routes | Yes |
| GET | `/routes/:routeId` | Get route by ID | Yes |
| PUT | `/routes/:routeId` | Update route | Yes |
| DELETE | `/routes/:routeId` | Delete route | Yes |
| **Drivers** |
| POST | `/drivers/invite` | Invite driver | Yes |
| GET | `/drivers` | Get my drivers | Yes |
| GET | `/drivers/:driverId` | Get driver by ID | Yes |
| PUT | `/drivers/:driverId/assign-bus` | Assign driver to bus | Yes |
| PUT | `/drivers/:driverId` | Update driver | Yes |
| DELETE | `/drivers/:driverId` | Delete driver | Yes |
| **Schedules** |
| POST | `/schedules` | Create schedule | Yes |
| GET | `/schedules` | Get schedules | Yes |
| GET | `/schedules/:scheduleId` | Get schedule by ID | Yes |
| PUT | `/schedules/:scheduleId` | Update schedule | Yes |
| DELETE | `/schedules/:scheduleId` | Delete schedule | Yes |
| **Audit** |
| GET | `/audit-logs` | Get audit logs | Yes |

---

## Driver APIs

**Base URL:** `/api/driver`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| **Authentication** |
| POST | `/register` | Register driver (with optional OTP) | No |
| POST | `/login` | Login driver (with optional OTP) | No |
| POST | `/verify-otp` | Verify OTP standalone | No |
| POST | `/register-with-invitation` | Register with invitation code | No |
| **Profile** |
| GET | `/profile` | Get profile | Yes (driverProtect) |
| PUT | `/profile` | Update profile | Yes (driverProtect) |
| **Buses** |
| GET | `/assigned-buses` | Get assigned buses | Yes (driverProtect) |
| GET | `/bus/:busId` | Get bus details | Yes (driverProtect) |
| GET | `/dashboard` | Get driver dashboard | Yes (driverProtect) |
| **Trip Management** |
| GET | `/trip-status` | Get trip status | Yes (driverProtect) |
| POST | `/mark-reached` | Mark destination reached | Yes (driverProtect) |
| **Location Sharing** |
| POST | `/location/start` | Start location sharing | Yes (driverProtect) |
| POST | `/location/stop` | Stop location sharing | Yes (driverProtect) |
| **Requests** |
| GET | `/pending-requests` | Get pending requests | Yes (driverProtect) |
| POST | `/accept-request/:requestId` | Accept request | Yes (driverProtect) |
| POST | `/reject-request/:requestId` | Reject request | Yes (driverProtect) |
| **Invitation (Owner/Counter/Admin)** |
| POST | `/invite` | Invite driver (send OTP) | Yes (protect + ownerOrCounterOrAdmin) |

---

## Key Features

### Counter Features

1. **Bus Access Request System:**
   - Counter requests access to owner's buses
   - Owner approves/rejects with seat allocation
   - Counter can only book allocated seats

2. **Booking Management:**
   - Create bookings for passengers
   - Only book seats in `allowedSeats` list
   - Automatic commission calculation
   - Support for offline mode

3. **Driver Management:**
   - Invite drivers with OTP
   - Manage assigned drivers
   - Assign drivers to legacy buses

4. **Sales & Analytics:**
   - Dashboard with today's stats
   - Sales summary by period
   - Booking analytics

### Driver Features

1. **OTP-Based Association:**
   - Owner/Counter sends OTP to driver email
   - Driver registers/logs in with OTP
   - Automatic association with owner

2. **Registration Options:**
   - Register with OTP (associates immediately)
   - Register without OTP (associate later via login)
   - Register with invitation code (legacy)

3. **Trip Management:**
   - View assigned buses
   - Track trip status
   - Mark destination reached
   - Share GPS location

4. **Request Management:**
   - View pending bus assignment requests
   - Accept/reject requests

---

## OTP Flow Summary

### Owner Adds Driver:
```
POST /api/owner/staff/driver
→ OTP sent to driver email
```

### Driver Registers with OTP:
```
POST /api/driver/register
Body: { ..., hasOTP: true, otp: "123456" }
→ Driver registered + associated with owner
```

### Driver Logs In with OTP:
```
POST /api/driver/login
Body: { email, password, hasOTP: true, otp: "123456" }
→ Login successful + associated with owner
```

---

## Counter Bus Access Flow

### Step 1: Counter Requests Access
```
POST /api/counter/request-bus-access
Body: { busId, requestedSeats: ["A1", "A2"] }
→ Request created (status: PENDING)
```

### Step 2: Owner Approves
```
POST /api/owner/counter-requests/:requestId/approve
Body: { allowedSeats: ["A1", "A2"] } // Optional override
→ Request approved + CounterBusAccess created
```

### Step 3: Counter Can Book
```
POST /api/counter/bookings
Body: { busId, seatNumbers: ["A1"] }
→ Booking created (only if seat in allowedSeats)
```

---

## Authentication Headers

All protected endpoints require:

```
Authorization: Bearer <your_jwt_token>
```

---

## Response Format

All endpoints return:

**Success:**
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { /* response data */ }
}
```

**Error:**
```json
{
  "success": false,
  "message": "Error message"
}
```

---

**Last Updated:** 2024-01-15  
**Version:** 1.0.0
