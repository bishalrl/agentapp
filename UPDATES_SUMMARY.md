# Application Updates Summary

**Date:** 2024  
**Based on:** Updated API documentation (COUNTER_API_DOCUMENTATION.md, COUNTER_DRIVER_API_QUICK_REFERENCE.md, DRIVER_API_DOCUMENTATION.md)

---

## ✅ Completed Updates

### 1. API Constants Updated
- ✅ Added Counter Request Management endpoints:
  - `counterRequestBusAccess = '/counter/request-bus-access'` (POST)
  - `counterRequests = '/counter/requests'` (GET)
- ✅ Marked Counter Bus Creation endpoints as LEGACY with comments
- ✅ All endpoints properly documented

### 2. Driver OTP-Based Association Support
- ✅ Updated `DriverRemoteDataSource` interface and implementation:
  - Added `hasOTP` and `otp` parameters to `register()` method
  - Added `hasOTP` and `otp` parameters to `login()` method
- ✅ Updated `DriverRepository` interface and implementation:
  - Added OTP parameters to register and login methods
- ✅ Updated Use Cases:
  - `RegisterDriver` now accepts `hasOTP` and `otp`
  - `DriverLogin` now accepts `hasOTP` and `otp`
- ✅ Updated Events:
  - `RegisterDriverEvent` now includes `hasOTP` and `otp` fields
  - `DriverLoginEvent` now includes `hasOTP` and `otp` fields
- ✅ Updated Bloc handlers to pass OTP parameters

**How it works:**
- Driver can register/login with `hasOTP: true` and `otp: "123456"` to associate with owner
- OTP is validated and driver is automatically associated with the owner who sent the invitation
- OTP is cleared after successful association

---

## ⏳ Pending Updates

### 1. Counter Request Management Feature (NEW)
**Status:** Not yet implemented - requires full feature creation

**Required Implementation:**
- **Data Layer:**
  - `counter_request_remote_data_source.dart` - API communication
  - `counter_request_model.dart` - Data models
  - `counter_request_repository_impl.dart` - Repository implementation
- **Domain Layer:**
  - `counter_request_entity.dart` - Business entities
  - `counter_request_repository.dart` - Repository interface
  - Use cases:
    - `request_bus_access.dart` - Request access to bus with seats
    - `get_counter_requests.dart` - Get all requests made by counter
- **Presentation Layer:**
  - `counter_request_bloc.dart` - State management
  - `counter_request_event.dart` - Event definitions
  - `counter_request_state.dart` - State definitions
  - `request_bus_access_page.dart` - UI for requesting bus access
  - `counter_requests_list_page.dart` - UI for viewing requests

**API Endpoints:**
- `POST /api/counter/request-bus-access` - Request bus access
- `GET /api/counter/requests` - Get all requests

**Features:**
- Counter can request access to owner's buses
- Specify which seats they want access to
- View all pending/approved/rejected requests
- Request expires after 7 days if not approved

### 2. Counter Booking Validation
**Status:** Backend handles this - frontend may need UI updates

**Note:** According to documentation, the backend already validates that counters can only book seats in their `allowedSeats` list. The frontend should:
- Display `allowedSeats` to counter when viewing bus details
- Only allow selection of seats in `allowedSeats` list
- Show clear error if trying to book unauthorized seats

**Current Status:** Booking logic exists but may need UI updates to show/hide seats based on `allowedSeats`.

### 3. Driver Invitation Flow
**Status:** Already using OTP (from documentation)

**Note:** According to the documentation, driver invitation already uses OTP:
- Counter/Owner invites driver via `POST /api/counter/drivers/invite` or `POST /api/driver/invite`
- OTP is sent to driver's email
- Driver registers/logs in with OTP to associate

**Current Status:** The invitation endpoint exists. The OTP flow is now supported in registration/login (completed above).

---

## 📋 Implementation Notes

### Counter Bus Access Flow (New)
1. **Counter requests access:**
   ```
   POST /api/counter/request-bus-access
   Body: { busId, requestedSeats: ["A1", "A2"], message }
   ```

2. **Owner approves/rejects:**
   - Owner approves via owner app (not counter app)
   - Creates `CounterBusAccess` record with `allowedSeats`

3. **Counter can book:**
   - Counter can only book seats in `allowedSeats` list
   - Backend validates this automatically

### Driver OTP Flow (Updated)
1. **Owner/Counter invites driver:**
   ```
   POST /api/counter/drivers/invite
   Body: { name, phoneNumber, email, licenseNumber, busId? }
   → OTP sent to driver's email
   ```

2. **Driver registers with OTP:**
   ```
   POST /api/driver/register
   Body: { ..., hasOTP: true, otp: "123456" }
   → Driver registered + associated with owner
   ```

3. **OR Driver logs in with OTP:**
   ```
   POST /api/driver/login
   Body: { email, password, hasOTP: true, otp: "123456" }
   → Login successful + associated with owner
   ```

---

## 🔄 Next Steps

1. **Create Counter Request Management Feature:**
   - Implement full feature following clean architecture
   - Add UI pages for requesting and viewing requests
   - Integrate with existing bus management

2. **Update Booking UI:**
   - Show `allowedSeats` in bus details
   - Filter seat selection to only `allowedSeats`
   - Add validation messages

3. **Update Driver Invitation UI:**
   - Ensure OTP fields are available in registration/login forms
   - Add UI for entering OTP during registration/login

4. **Testing:**
   - Test OTP-based driver association
   - Test counter request flow
   - Test booking with `allowedSeats` validation

---

## 📝 Files Modified

### Updated Files:
1. `lib/core/constants/api_constants.dart` - Added counter request endpoints, marked legacy endpoints
2. `lib/features/bus_driver/data/datasources/driver_remote_data_source.dart` - Added OTP support
3. `lib/features/bus_driver/domain/repositories/driver_repository.dart` - Added OTP parameters
4. `lib/features/bus_driver/data/repositories/driver_repository_impl.dart` - Pass OTP parameters
5. `lib/features/bus_driver/domain/usecases/register_driver.dart` - Added OTP support
6. `lib/features/bus_driver/domain/usecases/driver_login.dart` - Added OTP support
7. `lib/features/bus_driver/presentation/bloc/events/driver_event.dart` - Added OTP fields to events
8. `lib/features/bus_driver/presentation/bloc/driver_bloc.dart` - Pass OTP to use cases

### Files to Create (Counter Request Management):
- `lib/features/counter_request/` (full feature structure)

---

**Last Updated:** 2024  
**Status:** Core updates completed, Counter Request Management feature pending
