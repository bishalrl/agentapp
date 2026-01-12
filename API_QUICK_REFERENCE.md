# Counter API Quick Reference

## Base URLs
- **New APIs:** `/api/counter/*`
- **Legacy APIs:** `/api/bus-agent/*` (backward compatible)

## Authentication
```
Authorization: Bearer <token>
```

---

## 🔐 Authentication & Registration

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register-bus-agent` | Register new counter (with file uploads) |
| POST | `/api/auth/login-bus-agent` | Login counter |
| POST | `/api/auth/bus-agent-change-password` | Change password |
| POST | `/api/auth/forgot-password-counter` | Request password reset |
| POST | `/api/auth/reset-password-counter` | Reset password with token |
| GET | `/api/auth/me-bus-agent` | Get current counter profile |

---

## 👤 Profile Management

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/counter/profile` | Get profile |
| PUT | `/api/counter/profile` | Update profile (with avatar upload) |

---

## 📊 Dashboard

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/counter/dashboard` | Get dashboard data (buses, stats) |

---

## 🚌 Bus Management

### Assigned Buses (by Admin/Owner)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/counter/buses` | Get assigned buses |
| GET | `/api/counter/buses/:busId` | Get bus details |

### Own Buses (Created by Counter)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/counter/buses` | Create bus |
| GET | `/api/counter/buses/my-buses` | Get my buses |
| GET | `/api/counter/buses/my-buses/:busId` | Get my bus details |
| PUT | `/api/counter/buses/my-buses/:busId` | Update my bus |
| DELETE | `/api/counter/buses/my-buses/:busId` | Delete my bus |

---

## 🎫 Booking Management

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/counter/bookings` | Create booking (multi-seat) |
| GET | `/api/counter/bookings` | Get all bookings |
| GET | `/api/counter/bookings/:bookingId` | Get booking details |
| PUT | `/api/counter/bookings/:bookingId/cancel` | Cancel booking |
| PUT | `/api/counter/bookings/cancel-multiple` | Cancel multiple bookings |
| PATCH | `/api/counter/bookings/:id/status` | Update booking status |

---

## 👨‍✈️ Driver Management

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/counter/drivers/invite` | Invite driver (with OTP) |
| GET | `/api/counter/drivers` | Get my drivers |
| GET | `/api/counter/drivers/:driverId` | Get driver details |
| PUT | `/api/counter/drivers/:driverId/assign-bus` | Assign driver to bus |
| PUT | `/api/counter/drivers/:driverId` | Update driver |
| DELETE | `/api/counter/drivers/:driverId` | Delete driver |

---

## 🗺️ Route Management

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/counter/routes` | Create route |
| GET | `/api/counter/routes` | Get my routes |
| GET | `/api/counter/routes/:routeId` | Get route details |
| PUT | `/api/counter/routes/:routeId` | Update route |
| DELETE | `/api/counter/routes/:routeId` | Delete route |

---

## 📅 Schedule Management

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/counter/schedules` | Create schedule |
| GET | `/api/counter/schedules` | Get schedules |
| GET | `/api/counter/schedules/:scheduleId` | Get schedule details |
| PUT | `/api/counter/schedules/:scheduleId` | Update schedule |
| DELETE | `/api/counter/schedules/:scheduleId` | Delete schedule |

---

## 💰 Wallet Management

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/counter/wallet/add` | Add money to wallet |
| GET | `/api/counter/wallet/transactions` | Get transactions |

---

## 🔔 Notifications

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/counter/notifications` | Get notifications |
| POST | `/api/counter/notifications/mark-read` | Mark as read |
| POST | `/api/counter/notifications/mark-all-read` | Mark all as read |
| DELETE | `/api/counter/notifications/:id` | Delete notification |
| DELETE | `/api/counter/notifications` | Delete all notifications |

---

## 📈 Sales & Reports

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/counter/sales/summary` | Get sales summary |

---

## 📴 Offline Mode

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/counter/offline/queue` | Get offline queue |
| POST | `/api/counter/offline/queue` | Add to offline queue |
| POST | `/api/counter/offline/sync` | Sync offline bookings |

---

## 📋 Audit Logs

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/counter/audit-logs` | Get audit logs |

---

## Common Query Parameters

Most list endpoints support:
- `page` - Page number (default: 1)
- `limit` - Items per page (default: 10)
- `date` - Filter by date (YYYY-MM-DD)
- `status` - Filter by status
- `startDate` / `endDate` - Date range filters

---

## Response Format

**Success:**
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... }
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

## File Uploads

Endpoints that accept files use `multipart/form-data`:
- Registration: `citizenshipFile`, `photoFile`, `panFile`, `registrationFile`
- Profile: `avatar`
- Bus: `mainImage`, `galleryImages`

---

*For detailed API documentation, see `COUNTER_API_DOCUMENTATION.md`*
