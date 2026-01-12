# Bus Counter / Agent API List

## Complete List of All Counter/Agent APIs

This document provides a comprehensive list of all APIs created for the Bus Counter / Agent module, organized by functionality.

---

## 📊 Dashboard & Bus Management (3 APIs)

### 1. Get Counter Dashboard
- **Endpoint**: `GET /api/counter/dashboard`
- **Purpose**: Returns counter dashboard with assigned buses (grouped by date/route), today's statistics, and wallet balance
- **Key Features**:
  - Buses grouped by date and route
  - Real-time trip status (Scheduled/Departed/Completed)
  - Today's sales summary (total bookings, cash vs online sales)

### 2. Get Assigned Buses
- **Endpoint**: `GET /api/counter/buses`
- **Purpose**: Get all buses assigned to counter with real-time seat availability
- **Query Parameters**: `date`, `route`, `status`, `owner`
- **Key Features**:
  - Real-time seat availability (booked, locked, available)
  - Trip status calculation
  - Commission and booking stats per bus

### 3. Get Bus Details
- **Endpoint**: `GET /api/counter/buses/:busId`
- **Purpose**: Get detailed information about a specific bus
- **Key Features**:
  - Real-time seat map (booked, locked, available)
  - Lock details (who locked, expiration time)
  - Access control validation

---

## 🎫 Booking Management (4 APIs)

### 4. Create Booking
- **Endpoint**: `POST /api/counter/bookings`
- **Purpose**: Create new booking with seat locking and payment handling
- **Request Body**: `busId`, `seatNumbers[]`, `passengerName`, `contactNumber`, `passengerEmail`, `paymentMethod`
- **Key Features**:
  - Automatic seat locking (10-minute expiration)
  - Multiple payment methods (cash, online, wallet)
  - Real-time Socket.IO notifications
  - Automatic commission calculation
  - Ticket PDF generation
  - Conflict prevention (double booking)

### 5. Get All Bookings
- **Endpoint**: `GET /api/counter/bookings`
- **Purpose**: Get all bookings made by counter with filters
- **Query Parameters**: `date`, `busId`, `status`, `paymentMethod`
- **Key Features**:
  - Filter by date, bus, status, payment method
  - Auto-complete past bookings
  - Booking history with details

### 6. Get Booking Details
- **Endpoint**: `GET /api/counter/bookings/:bookingId`
- **Purpose**: Get detailed information about a specific booking
- **Key Features**:
  - Complete booking information
  - Bus details included
  - Payment and passenger details

### 7. Cancel Booking
- **Endpoint**: `PUT /api/counter/bookings/:bookingId/cancel`
- **Purpose**: Cancel a booking with automatic refund calculation
- **Key Features**:
  - Refund policy: 100% (>48h), 75% (>24h), 50% (>12h), 0% (<12h)
  - Automatic wallet refund for online/wallet payments
  - Real-time Socket.IO notifications
  - Bus seat count update

---

## 💰 Sales & Reports (1 API)

### 8. Get Sales Summary
- **Endpoint**: `GET /api/counter/sales/summary`
- **Purpose**: Get comprehensive sales summary with analytics
- **Query Parameters**: `startDate`, `endDate`, `busId`
- **Key Features**:
  - Daily totals (bookings, sales)
  - Payment method breakdown (cash, online, wallet)
  - Per-bus sales statistics
  - Date range filtering
  - Defaults to today if no date range provided

---

## 📴 Offline Mode (3 APIs)

### 9. Get Offline Queue
- **Endpoint**: `GET /api/counter/offline/queue`
- **Purpose**: Get all bookings in offline queue (pending sync)
- **Key Features**:
  - View pending, synced, failed, and conflict bookings
  - Sync attempt tracking
  - Error messages for failed syncs

### 10. Add to Offline Queue
- **Endpoint**: `POST /api/counter/offline/queue`
- **Purpose**: Add booking to offline queue when network is unavailable
- **Request Body**: Same as create booking
- **Key Features**:
  - Store bookings locally when offline
  - Queue for later sync
  - Maintains all booking details

### 11. Sync Offline Bookings
- **Endpoint**: `POST /api/counter/offline/sync`
- **Purpose**: Manually trigger synchronization of pending offline bookings
- **Key Features**:
  - Batch sync all pending bookings
  - Conflict detection (seats already booked)
  - Error handling and reporting
  - Automatic booking creation on success

---

## 📋 Audit Logs (1 API)

### 12. Get Audit Logs
- **Endpoint**: `GET /api/counter/audit-logs`
- **Purpose**: Get audit logs for all counter actions
- **Query Parameters**: `action`, `startDate`, `endDate`, `limit`
- **Key Features**:
  - Track all counter operations
  - Filter by action type
  - Date range filtering
  - IP address and user agent tracking
  - Fraud prevention support

---

## 🔐 Authentication

All endpoints require JWT Bearer token authentication:
```
Authorization: Bearer <token>
```

---

## 📡 Socket.IO Events

### Events Emitted by Server:
1. **`seats:locked`** - When seats are locked
2. **`seats:booked`** - When seats are confirmed booked
3. **`booking:created`** - When new booking is created
4. **`booking:cancelled`** - When booking is cancelled

### Events to Emit from Client (Optional):
- `subscribe:bus:<busId>` - Subscribe to bus updates
- `unsubscribe:bus:<busId>` - Unsubscribe from bus updates

---

## 🎯 Key Features Summary

✅ **Real-time Seat Locking** - Prevents double booking across multiple counters  
✅ **Offline Mode Support** - Queue bookings when network is down, sync when online  
✅ **Multiple Payment Methods** - Cash, online, wallet support  
✅ **Automatic Commission** - Calculated and credited to counter wallet  
✅ **Sales Analytics** - Daily, per-bus, payment method breakdown  
✅ **Audit Logging** - All actions tracked for fraud prevention and reconciliation  
✅ **Socket.IO Integration** - Real-time updates for seat availability  
✅ **Access Control** - Counters can only access assigned buses  
✅ **Seat Restrictions** - Support for allowed seats per counter  
✅ **Refund Policy** - Automatic refund calculation based on cancellation timing  

---

## 📚 Documentation Files

1. **COUNTER_AGENT_API_DOCUMENTATION.md** - Complete API documentation with request/response examples
2. **COUNTER_API_QUICK_REFERENCE.md** - Quick reference guide for developers
3. **COUNTER_API_LIST.md** - This file (complete API list)

---

## 🔄 Integration Flow

### Booking Flow:
1. Counter selects bus → `GET /api/counter/buses/:busId`
2. Counter selects seats → `POST /api/counter/bookings` (seats auto-locked)
3. Payment processed → Booking confirmed → Lock released
4. Socket.IO events broadcast to all users/counters

### Offline Flow:
1. Network unavailable → `POST /api/counter/offline/queue`
2. Connection restored → `POST /api/counter/offline/sync`
3. Server validates → Creates booking or marks conflict

### Sales Reporting Flow:
1. Counter views dashboard → `GET /api/counter/dashboard`
2. Counter views detailed sales → `GET /api/counter/sales/summary`
3. Counter views per-bus stats → Included in sales summary

---

## ✅ Testing Checklist

- [x] Dashboard loads with assigned buses
- [x] Bus list filters work correctly
- [x] Real-time seat availability updates
- [x] Seat locking prevents double booking
- [x] Booking creation with all payment methods
- [x] Booking cancellation with refund calculation
- [x] Sales summary shows correct totals
- [x] Offline queue stores and syncs bookings
- [x] Audit logs capture all actions
- [x] Socket.IO events broadcast correctly
- [x] Access control prevents unauthorized access
- [x] Allowed seats restriction works

---

## 📝 Notes

- All APIs use consistent response format: `{ success: boolean, data: {}, message: string }`
- All errors follow standard format: `{ success: false, message: string }`
- Seat locks expire after 10 minutes
- Commission is automatically calculated: `bus.commissionRate * bus.price * seatCount`
- Refund policy: 100% (>48h), 75% (>24h), 50% (>12h), 0% (<12h)
- All actions are logged in `CounterAuditLog` for audit purposes

---

**Total APIs Created**: 12  
**Models Created**: 2 (CounterAuditLog, OfflineBookingQueue)  
**Controller**: `backend/controllers/counterController.js`  
**Routes**: `backend/routes/counterRoutes.js`  
**Base Path**: `/api/counter`

---

**Last Updated**: 2024-01-15  
**Version**: 1.0.0

