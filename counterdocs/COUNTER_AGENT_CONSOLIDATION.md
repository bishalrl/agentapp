# Counter / Agent System Consolidation

## Overview
This document explains the consolidation of Counter and Agent systems to ensure no duplication and proper integration.

---

## Terminology

**Counter = BusAgent**: These terms refer to the same entity in the system.
- **Model**: `BusAgent` (database model)
- **Routes**: 
  - `/api/bus-agent` (legacy routes, maintained for backward compatibility)
  - `/api/counter` (new routes, recommended for new implementations)

---

## Route Consolidation

### Current State

1. **Legacy Routes** (`/api/bus-agent`):
   - Uses `busAgentController.js`
   - Maintained for backward compatibility
   - Endpoints: profile, bookings, buses, notifications, wallet

2. **New Routes** (`/api/counter`):
   - Uses `counterController.js`
   - Comprehensive counter/agent functionality
   - Endpoints: dashboard, buses, bookings, sales, offline mode, audit logs

### Recommendation

- **For Mobile Apps**: Use `/api/counter` routes (new, comprehensive)
- **For Legacy Systems**: Continue using `/api/bus-agent` routes
- **Both routes work with the same `BusAgent` model** - no data duplication

---

## Driver Association Logic

### Problem
When adding buses, only `driverContact` (string) was set, but `driverId` (ObjectId) was not. This broke driver association.

### Solution
Created `backend/utils/driverAssociation.js` utility that:
1. Finds driver by phone number when `driverContact` is provided
2. Sets `driverId` on the bus
3. Updates driver's `assignedBusIds` array
4. Maintains bidirectional relationship

### Implementation

#### When Adding Bus:
```javascript
// If driverContact provided, automatically find and associate driver
if (driverContact && !driverId) {
  await associateDriverToBus(driverContact, busId);
}

// If driverId provided directly, update driver's assigned buses
if (driverId) {
  // Update driver.assignedBusIds
}
```

#### When Updating Bus:
```javascript
// If driverContact changes, disassociate old driver and associate new one
if (driverContact && driverContact !== bus.driverContact) {
  await disassociateDriverFromBus(bus._id);
  await associateDriverToBus(driverContact, bus._id);
}
```

### Files Updated

1. **`backend/utils/driverAssociation.js`** (NEW):
   - `associateDriverToBus(driverContact, busId)` - Find driver by phone and associate
   - `disassociateDriverFromBus(busId)` - Remove driver association

2. **`backend/controllers/adminController.js`**:
   - `addBus()` - Now associates driver automatically
   - `updateBus()` - Handles driver reassignment

3. **`backend/controllers/busOwnerController.js`**:
   - `addMyBus()` - Now associates driver automatically
   - `updateMyBus()` - Handles driver reassignment

---

## Bus Creation Flow

### Admin Adding Bus:
1. Admin provides `driverContact` (phone number) or `driverId`
2. If `driverContact` provided:
   - System searches for driver by phone number
   - If found and verified: Sets `bus.driverId` and updates `driver.assignedBusIds`
   - If not found: Bus created with `driverContact` only (backward compatible)
3. If `driverId` provided directly:
   - System validates driver exists
   - Sets `bus.driverId` and updates `driver.assignedBusIds`

### Owner Adding Bus:
Same logic as admin, but also sets `ownerId` field.

---

## Driver Model Updates

The `Driver` model maintains:
- `assignedBusId` - Primary assigned bus (single)
- `assignedBusIds[]` - All assigned buses (array)

When bus is created/updated:
- Driver's `assignedBusIds` is updated
- If `assignedBusId` is null, first bus becomes primary

---

## Counter/Agent Model

**Single Model**: `BusAgent`
- No duplication
- Both `/api/bus-agent` and `/api/counter` use same model
- Same authentication (JWT with BusAgent model)

---

## Testing Checklist

- [x] Bus creation with `driverContact` associates driver correctly
- [x] Bus creation with `driverId` associates driver correctly
- [x] Bus update with new `driverContact` reassociates driver
- [x] Driver's `assignedBusIds` is updated correctly
- [x] Both `/api/bus-agent` and `/api/counter` work with same data
- [x] No data duplication between counter and agent
- [x] Driver association works for admin-added buses
- [x] Driver association works for owner-added buses

---

## Migration Notes

### For Existing Buses:
Existing buses may have `driverContact` but no `driverId`. To fix:

```javascript
// Run migration script to associate existing drivers
const { associateDriverToBus } = require('./utils/driverAssociation');
const buses = await Bus.find({ driverContact: { $exists: true }, driverId: null });
for (const bus of buses) {
  await associateDriverToBus(bus.driverContact, bus._id);
}
```

---

## API Endpoints Summary

### Counter Routes (`/api/counter`) - Recommended
- Dashboard, buses, bookings, sales, offline mode, audit logs

### Bus Agent Routes (`/api/bus-agent`) - Legacy
- Profile, bookings, buses, notifications, wallet

**Both work with same `BusAgent` model - no duplication!**

---

**Last Updated**: 2024-01-15
**Version**: 1.0.0

