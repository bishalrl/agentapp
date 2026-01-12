# Feature Analysis and Implementation Plan

## Executive Summary

This document provides a comprehensive analysis of the Counter Agent App features, comparing the implementation status against the API documentation (`API_QUICK_REFERENCE.md` and `COUNTER_API_DOCUMENTATION.md`). It identifies missing features, verifies API alignment, and provides an implementation plan.

**Analysis Date:** 2026-01-11  
**Documentation Reviewed:**
- `API_QUICK_REFERENCE.md`
- `COUNTER_API_DOCUMENTATION.md`

---

## 1. Feature Implementation Status

### ✅ Fully Implemented Features

#### 1.1 Authentication & Registration
| Feature | Endpoint | Status | Notes |
|---------|----------|--------|-------|
| Register Counter | `POST /api/auth/register-bus-agent` | ✅ Implemented | With file uploads (citizenship, photo, PAN, registration) |
| Login Counter | `POST /api/auth/login-bus-agent` | ✅ Implemented | Returns token and counter data |
| Change Password | `POST /api/auth/bus-agent-change-password` | ✅ Implemented | Change password after first login |
| Get Current Profile (Auth) | `GET /api/auth/me-bus-agent` | ⚠️ Partial | Not explicitly implemented, but login returns profile |

#### 1.2 Dashboard
| Feature | Endpoint | Status | Notes |
|---------|----------|--------|-------|
| Get Dashboard | `GET /api/counter/dashboard` | ✅ Implemented | Shows assigned buses, today's stats, wallet balance |

#### 1.3 Bus Management (Own Buses)
| Feature | Endpoint | Status | Notes |
|---------|----------|--------|-------|
| Create Bus | `POST /api/counter/buses` | ✅ Implemented | Creates bus owned by counter |
| Get My Buses | `GET /api/counter/buses/my-buses` | ⚠️ Partial | Uses `/counter/buses` instead of `/counter/buses/my-buses` |
| Get My Bus Details | `GET /api/counter/buses/my-buses/:busId` | ❌ Missing | Not implemented |
| Update My Bus | `PUT /api/counter/buses/my-buses/:busId` | ⚠️ Partial | Uses `/counter/buses/:id` instead of `/counter/buses/my-buses/:id` |
| Delete My Bus | `DELETE /api/counter/buses/my-buses/:busId` | ⚠️ Partial | Uses `/counter/buses/:id` instead of `/counter/buses/my-buses/:id` |

#### 1.4 Booking Management
| Feature | Endpoint | Status | Notes |
|---------|----------|--------|-------|
| Create Booking | `POST /api/counter/bookings` | ✅ Implemented | Multi-seat booking with payment methods |
| Get All Bookings | `GET /api/counter/bookings` | ✅ Implemented | With filters (date, busId, status, paymentMethod) |
| Get Booking Details | `GET /api/counter/bookings/:bookingId` | ✅ Implemented | Complete booking information |
| Cancel Booking | `PUT /api/counter/bookings/:bookingId/cancel` | ✅ Implemented | Single booking cancellation |

#### 1.5 Route Management
| Feature | Endpoint | Status | Notes |
|---------|----------|--------|-------|
| Create Route | `POST /api/counter/routes` | ✅ Implemented | With stops support |
| Get My Routes | `GET /api/counter/routes` | ✅ Implemented | All routes created by counter |
| Get Route Details | `GET /api/counter/routes/:routeId` | ✅ Implemented | Complete route information |
| Update Route | `PUT /api/counter/routes/:routeId` | ✅ Implemented | Update route details |
| Delete Route | `DELETE /api/counter/routes/:routeId` | ✅ Implemented | Delete route |

#### 1.6 Seat Locking
| Feature | Endpoint | Status | Notes |
|---------|----------|--------|-------|
| Lock Seat | `POST /api/seat-lock/lock` | ✅ Implemented | Single seat locking |
| Lock Multiple Seats | `POST /api/seat-lock/lock-multiple` | ✅ Implemented | Multiple seat locking |
| Unlock Seat | `POST /api/seat-lock/unlock` | ✅ Implemented | Unlock seat |

---

### ❌ Missing Features

#### 2.1 Profile Management
| Feature | Endpoint | Status | Priority |
|---------|----------|--------|----------|
| Get Profile | `GET /api/counter/profile` | ❌ Missing | High |
| Update Profile | `PUT /api/counter/profile` | ❌ Missing | High |

**Impact:** Users cannot view or update their profile information, including avatar upload.

#### 2.2 Bus Management (Assigned Buses)
| Feature | Endpoint | Status | Priority |
|---------|----------|--------|----------|
| Get Assigned Buses | `GET /api/counter/buses` | ⚠️ Partial | High |
| Get Bus Details (Assigned) | `GET /api/counter/buses/:busId` | ⚠️ Partial | High |

**Current Issue:** The app uses `/counter/buses` for both assigned buses and own buses. According to docs:
- `/counter/buses` should return **assigned buses** (by admin/owner)
- `/counter/buses/my-buses` should return **own buses** (created by counter)

**Impact:** Cannot distinguish between assigned buses and own buses properly.

#### 2.3 Booking Management (Missing Operations)
| Feature | Endpoint | Status | Priority |
|---------|----------|--------|----------|
| Cancel Multiple Bookings | `PUT /api/counter/bookings/cancel-multiple` | ❌ Missing | Medium |
| Update Booking Status | `PATCH /api/counter/bookings/:id/status` | ❌ Missing | Medium |

**Impact:** Cannot cancel multiple bookings at once or update booking status manually.

#### 2.4 Driver Management
| Feature | Endpoint | Status | Priority |
|---------|----------|--------|----------|
| Invite Driver | `POST /api/counter/drivers/invite` | ❌ Missing | High |
| Get My Drivers | `GET /api/counter/drivers` | ❌ Missing | High |
| Get Driver Details | `GET /api/counter/drivers/:driverId` | ❌ Missing | High |
| Assign Driver to Bus | `PUT /api/counter/drivers/:driverId/assign-bus` | ❌ Missing | High |
| Update Driver | `PUT /api/counter/drivers/:driverId` | ❌ Missing | Medium |
| Delete Driver | `DELETE /api/counter/drivers/:driverId` | ❌ Missing | Medium |

**Impact:** Cannot manage drivers, which is essential for bus operations.

#### 2.5 Schedule Management
| Feature | Endpoint | Status | Priority |
|---------|----------|--------|----------|
| Create Schedule | `POST /api/counter/schedules` | ❌ Missing | High |
| Get Schedules | `GET /api/counter/schedules` | ❌ Missing | High |
| Get Schedule Details | `GET /api/counter/schedules/:scheduleId` | ❌ Missing | High |
| Update Schedule | `PUT /api/counter/schedules/:scheduleId` | ❌ Missing | Medium |
| Delete Schedule | `DELETE /api/counter/schedules/:scheduleId` | ❌ Missing | Medium |

**Impact:** Cannot create or manage schedules for routes, which is critical for recurring trips.

#### 2.6 Wallet Management
| Feature | Endpoint | Status | Priority |
|---------|----------|--------|----------|
| Add Money to Wallet | `POST /api/counter/wallet/add` | ❌ Missing | High |
| Get Transactions | `GET /api/counter/wallet/transactions` | ❌ Missing | High |

**Impact:** Cannot add money to wallet or view transaction history, limiting financial operations.

#### 2.7 Notifications
| Feature | Endpoint | Status | Priority |
|---------|----------|--------|----------|
| Get Notifications | `GET /api/counter/notifications` | ❌ Missing | High |
| Mark as Read | `POST /api/counter/notifications/mark-read` | ❌ Missing | Medium |
| Mark All as Read | `POST /api/counter/notifications/mark-all-read` | ❌ Missing | Medium |
| Delete Notification | `DELETE /api/counter/notifications/:id` | ❌ Missing | Low |
| Delete All Notifications | `DELETE /api/counter/notifications` | ❌ Missing | Low |

**Impact:** Users cannot receive or manage notifications about bookings, cancellations, etc.

#### 2.8 Sales & Reports
| Feature | Endpoint | Status | Priority |
|---------|----------|--------|----------|
| Get Sales Summary | `GET /api/counter/sales/summary` | ❌ Missing | High |

**Impact:** Cannot view sales analytics and reports, limiting business insights.

#### 2.9 Offline Mode
| Feature | Endpoint | Status | Priority |
|---------|----------|--------|----------|
| Get Offline Queue | `GET /api/counter/offline/queue` | ❌ Missing | Medium |
| Add to Offline Queue | `POST /api/counter/offline/queue` | ❌ Missing | Medium |
| Sync Offline Bookings | `POST /api/counter/offline/sync` | ❌ Missing | Medium |

**Impact:** Cannot operate in offline mode, which is critical for areas with poor connectivity.

#### 2.10 Audit Logs
| Feature | Endpoint | Status | Priority |
|---------|----------|--------|----------|
| Get Audit Logs | `GET /api/counter/audit-logs` | ❌ Missing | Low |

**Impact:** Cannot view audit trail of actions for compliance and debugging.

---

## 2. API Alignment Analysis

### 2.1 API Endpoints in Code vs Documentation

#### ✅ Correctly Aligned
- Authentication endpoints match documentation
- Dashboard endpoint matches
- Booking endpoints (create, get, cancel single) match
- Route management endpoints match

#### ⚠️ Partially Aligned (Needs Fix)
1. **Bus Management Endpoints:**
   - **Current:** Uses `/counter/buses` for all operations
   - **Expected:** 
     - Assigned buses: `GET /counter/buses`
     - Own buses: `GET /counter/buses/my-buses`, `PUT /counter/buses/my-buses/:id`, `DELETE /counter/buses/my-buses/:id`
   - **Action Required:** Update bus management to use correct endpoints

2. **Get My Buses:**
   - **Current:** `GET /counter/buses` (returns all buses)
   - **Expected:** `GET /counter/buses/my-buses` (returns only counter's buses)
   - **Action Required:** Add separate endpoint for own buses

#### ❌ Missing API Constants
The following endpoints are defined in documentation but missing from `api_constants.dart`:
- `/counter/profile` (GET, PUT)
- `/counter/drivers/*` (all driver endpoints)
- `/counter/schedules/*` (all schedule endpoints)
- `/counter/wallet/*` (wallet endpoints)
- `/counter/notifications/*` (notification endpoints)
- `/counter/sales/summary`
- `/counter/offline/*` (offline endpoints - constants exist but not used)
- `/counter/audit-logs`
- `/counter/bookings/cancel-multiple`
- `/counter/bookings/:id/status`
- `/counter/buses/my-buses` (GET, PUT, DELETE variants)

---

## 3. Home/Dashboard Page Analysis

### Current Dashboard Features
The dashboard page (`dashboard_page.dart`) currently displays:

1. ✅ **Counter Info Card:**
   - Agency name
   - Email
   - Wallet balance

2. ✅ **Today's Statistics Card:**
   - Total bookings
   - Total sales
   - Cash sales
   - Online sales

3. ✅ **Assigned Buses Section:**
   - Buses grouped by date
   - Buses grouped by route
   - Bus details (name, time, seats, price)

### Missing Dashboard Features (from API response)
According to the API documentation, the dashboard should also include:
- ❌ **Buses by Date** (detailed breakdown)
- ❌ **Quick Actions** (create booking, add bus, etc.)
- ❌ **Recent Bookings** (last 5-10 bookings)
- ❌ **Notifications Badge** (unread count)
- ❌ **Upcoming Trips** (next 7 days)

### Navigation Issues
- **Current:** Only 2 navigation items (Dashboard, Bookings)
- **Missing Navigation Items:**
  - Profile
  - Buses (assigned + own)
  - Routes
  - Drivers
  - Schedules
  - Wallet
  - Notifications
  - Sales/Reports
  - Settings/Profile

---

## 4. Implementation Plan

### Phase 1: Critical Features (High Priority) - Week 1-2

#### 1.1 Profile Management
**Tasks:**
- [ ] Add API constants for profile endpoints
- [ ] Create profile data source (remote)
- [ ] Create profile models and entities
- [ ] Create profile repository
- [ ] Create profile use cases (get, update)
- [ ] Create profile BLoC
- [ ] Create profile page UI
- [ ] Add profile route
- [ ] Add profile navigation item

**Files to Create:**
```
lib/features/profile/
├── data/
│   ├── datasources/
│   │   └── profile_remote_data_source.dart
│   ├── models/
│   │   └── profile_model.dart
│   └── repositories/
│       └── profile_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── profile_entity.dart
│   ├── repositories/
│   │   └── profile_repository.dart
│   └── usecases/
│       ├── get_profile.dart
│       └── update_profile.dart
└── presentation/
    ├── bloc/
    │   ├── profile_bloc.dart
    │   ├── events/
    │   │   └── profile_event.dart
    │   └── states/
    │       └── profile_state.dart
    └── pages/
        └── profile_page.dart
```

#### 1.2 Fix Bus Management Endpoints
**Tasks:**
- [ ] Update `api_constants.dart` to add `/counter/buses/my-buses` endpoints
- [ ] Update `bus_remote_data_source.dart` to use correct endpoints:
  - Assigned buses: `GET /counter/buses`
  - Own buses: `GET /counter/buses/my-buses`
  - Update own bus: `PUT /counter/buses/my-buses/:id`
  - Delete own bus: `DELETE /counter/buses/my-buses/:id`
- [ ] Add `getAssignedBuses` method (separate from `getMyBuses`)
- [ ] Update UI to show distinction between assigned and own buses

#### 1.3 Driver Management
**Tasks:**
- [ ] Add API constants for all driver endpoints
- [ ] Create driver management feature (similar structure to bus management)
- [ ] Implement invite driver with OTP
- [ ] Implement get, update, delete drivers
- [ ] Implement assign driver to bus
- [ ] Create driver management UI pages

**Files to Create:**
```
lib/features/driver_management/
├── data/
│   ├── datasources/
│   │   └── driver_management_remote_data_source.dart
│   ├── models/
│   │   └── driver_management_model.dart
│   └── repositories/
│       └── driver_management_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── driver_management_entity.dart
│   ├── repositories/
│   │   └── driver_management_repository.dart
│   └── usecases/
│       ├── invite_driver.dart
│       ├── get_drivers.dart
│       ├── get_driver_by_id.dart
│       ├── assign_driver_to_bus.dart
│       ├── update_driver.dart
│       └── delete_driver.dart
└── presentation/
    ├── bloc/
    │   └── driver_management_bloc.dart
    └── pages/
        ├── driver_list_page.dart
        ├── invite_driver_page.dart
        └── driver_details_page.dart
```

#### 1.4 Schedule Management
**Tasks:**
- [ ] Add API constants for schedule endpoints
- [ ] Create schedule management feature
- [ ] Implement CRUD operations for schedules
- [ ] Create schedule management UI

**Files to Create:**
```
lib/features/schedule_management/
[Similar structure to route_management]
```

#### 1.5 Wallet Management
**Tasks:**
- [ ] Add API constants for wallet endpoints
- [ ] Create wallet feature
- [ ] Implement add money to wallet
- [ ] Implement get transactions
- [ ] Create wallet UI pages

**Files to Create:**
```
lib/features/wallet/
[Similar structure to other features]
```

### Phase 2: Important Features (High-Medium Priority) - Week 3-4

#### 2.1 Notifications
**Tasks:**
- [ ] Add API constants for notification endpoints
- [ ] Create notification feature
- [ ] Implement get, mark read, delete notifications
- [ ] Add notification badge to dashboard
- [ ] Create notification UI

#### 2.2 Sales & Reports
**Tasks:**
- [ ] Add API constant for sales summary
- [ ] Create sales feature
- [ ] Implement get sales summary with filters
- [ ] Create sales/reports UI page
- [ ] Add charts/graphs for visualization

#### 2.3 Booking Enhancements
**Tasks:**
- [ ] Add API constant for cancel multiple bookings
- [ ] Add API constant for update booking status
- [ ] Implement cancel multiple bookings
- [ ] Implement update booking status
- [ ] Update booking UI to support these features

### Phase 3: Nice-to-Have Features (Medium-Low Priority) - Week 5-6

#### 3.1 Offline Mode
**Tasks:**
- [ ] Implement offline queue management
- [ ] Add offline detection
- [ ] Implement sync when online
- [ ] Add offline indicator UI

#### 3.2 Audit Logs
**Tasks:**
- [ ] Add API constant for audit logs
- [ ] Create audit logs feature
- [ ] Implement get audit logs with filters
- [ ] Create audit logs UI page

### Phase 4: UI/UX Improvements - Week 7-8

#### 4.1 Dashboard Enhancements
**Tasks:**
- [ ] Add quick action buttons
- [ ] Add recent bookings section
- [ ] Add upcoming trips section
- [ ] Add notification badge
- [ ] Improve navigation (bottom nav or drawer)

#### 4.2 Navigation Improvements
**Tasks:**
- [ ] Add all missing navigation items
- [ ] Implement proper navigation structure
- [ ] Add settings/profile page link
- [ ] Add logout functionality

---

## 5. API Constants Update Required

Add the following to `lib/core/constants/api_constants.dart`:

```dart
// Profile Management
static const String counterProfile = '/counter/profile';

// Bus Management (Own Buses)
static const String counterMyBuses = '/counter/buses/my-buses';
static const String counterMyBusDetails = '/counter/buses/my-buses'; // GET with :id
static const String counterMyBusUpdate = '/counter/buses/my-buses'; // PUT with :id
static const String counterMyBusDelete = '/counter/buses/my-buses'; // DELETE with :id

// Driver Management
static const String counterDriversInvite = '/counter/drivers/invite';
static const String counterDrivers = '/counter/drivers';
static const String counterDriverDetails = '/counter/drivers'; // GET with :id
static const String counterDriverAssignBus = '/counter/drivers'; // PUT with :id/assign-bus
static const String counterDriverUpdate = '/counter/drivers'; // PUT with :id
static const String counterDriverDelete = '/counter/drivers'; // DELETE with :id

// Schedule Management
static const String counterSchedules = '/counter/schedules';
static const String counterScheduleCreate = '/counter/schedules';
static const String counterScheduleDetails = '/counter/schedules'; // GET with :id
static const String counterScheduleUpdate = '/counter/schedules'; // PUT with :id
static const String counterScheduleDelete = '/counter/schedules'; // DELETE with :id

// Wallet Management
static const String counterWalletAdd = '/counter/wallet/add';
static const String counterWalletTransactions = '/counter/wallet/transactions';

// Notifications
static const String counterNotifications = '/counter/notifications';
static const String counterNotificationsMarkRead = '/counter/notifications/mark-read';
static const String counterNotificationsMarkAllRead = '/counter/notifications/mark-all-read';
static const String counterNotificationDelete = '/counter/notifications'; // DELETE with :id
static const String counterNotificationsDeleteAll = '/counter/notifications';

// Booking Enhancements
static const String counterBookingsCancelMultiple = '/counter/bookings/cancel-multiple';
static const String counterBookingUpdateStatus = '/counter/bookings'; // PATCH with :id/status

// Sales & Reports (already exists but verify)
// static const String counterSalesSummary = '/counter/sales/summary';

// Offline Mode (already exists but verify usage)
// static const String counterOfflineQueue = '/counter/offline/queue';
// static const String counterOfflineSync = '/counter/offline/sync';

// Audit Logs (already exists but verify usage)
// static const String counterAuditLogs = '/counter/audit-logs';
```

---

## 6. Summary Statistics

### Implementation Status
- **Fully Implemented:** 15 features
- **Partially Implemented:** 3 features (bus management endpoints need fixing)
- **Missing:** 13 feature categories (40+ individual endpoints)

### Priority Breakdown
- **High Priority:** 8 feature categories (Profile, Bus fixes, Driver, Schedule, Wallet, Notifications, Sales, Booking enhancements)
- **Medium Priority:** 2 feature categories (Offline mode, Booking enhancements)
- **Low Priority:** 1 feature category (Audit logs)

### Estimated Timeline
- **Phase 1 (Critical):** 2 weeks
- **Phase 2 (Important):** 2 weeks
- **Phase 3 (Nice-to-Have):** 2 weeks
- **Phase 4 (UI/UX):** 2 weeks
- **Total:** 8 weeks for complete implementation

---

## 7. Recommendations

1. **Immediate Actions:**
   - Fix bus management endpoints to distinguish assigned vs own buses
   - Add profile management (essential for user experience)
   - Add wallet management (critical for financial operations)

2. **Short-term Actions:**
   - Implement driver management (essential for bus operations)
   - Implement schedule management (critical for recurring trips)
   - Add notifications (important for user engagement)

3. **Long-term Actions:**
   - Implement offline mode (important for areas with poor connectivity)
   - Add audit logs (useful for compliance and debugging)
   - Enhance dashboard with more features

4. **Code Quality:**
   - Ensure all API endpoints match documentation exactly
   - Add proper error handling for all new features
   - Add loading states and error states for all UI pages
   - Add proper navigation structure

---

## 8. Next Steps

1. Review this document with the development team
2. Prioritize features based on business needs
3. Create detailed task breakdowns for Phase 1
4. Start implementation with Profile Management
5. Update this document as features are completed

---

**Document Version:** 1.0  
**Last Updated:** 2026-01-11  
**Next Review:** After Phase 1 completion
