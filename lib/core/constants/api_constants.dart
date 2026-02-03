class ApiConstants {
  // Base URLs
  // ⚠️ IMPORTANT: Update this to your actual server IP address
  // For local development, use: http://YOUR_IP_ADDRESS:5000/api
  // To find your IP: Windows (ipconfig) or Mac/Linux (ifconfig)
  
  // Development/Testing (Local Network)
  // Backend Server IP: 192.168.1.68
  // Backend Server Port: 5000
  static const String baseUrl = 'http://192.168.1.68:5000/api';
  
  // Development URLs (for local testing)
  static const String devBaseUrl = 'http://192.168.1.68:5000/api';
  
  // Production (Update when deployed)
  // static const String baseUrl = 'https://your-production-domain.com/api';
  
  // Localhost (for emulator)
  // static const String baseUrl = 'http://10.0.2.2:5000/api'; // Android emulator
  // static const String baseUrl = 'http://localhost:5000/api'; // iOS simulator
  
  // API Endpoints
  static const String driverInvite = '/driver/invite';
  static const String driverVerifyOtp = '/driver/verify-otp';
  static const String driverRegister = '/driver/register'; // Independent registration (no invitation)
  static const String driverRegisterWithInvitation = '/driver/register-with-invitation';
  static const String driverLogin = '/driver/login';
  static const String driverDashboard = '/driver/dashboard';
  static const String driverProfile = '/driver/profile';
  static const String driverAssignedBuses = '/driver/assigned-buses';
  static const String driverBusDetails = '/driver/bus'; // GET /:busId
  static const String driverLocationStart = '/driver/location/start';
  static const String driverLocationStop = '/driver/location/stop';
  static const String driverTripStatus = '/driver/trip-status';
  static const String driverMarkReached = '/driver/mark-reached';
  static const String driverPendingRequests = '/driver/pending-requests';
  static const String driverAcceptRequest = '/driver/accept-request'; // POST /:requestId
  static const String driverRejectRequest = '/driver/reject-request'; // POST /:requestId
  
  // Driver Ride Management
  static const String driverRideInitiate = '/driver/ride/initiate'; // POST
  static const String driverLocationUpdate = '/driver/location/update'; // POST
  
  // Driver Booking
  static const String driverBookings = '/driver/bookings'; // POST create booking
  
  // Driver Scan/Ticket Verification
  static const String driverBusPassengers = '/driver/bus'; // GET /:busId/passengers
  static const String driverScanVerifyTicket = '/driver/scan/verify-ticket'; // POST
  
  // Driver Permission Requests
  static const String driverPermissionRequest = '/driver/permissions/request'; // POST
  static const String driverPermissionRequests = '/driver/permissions/requests'; // GET
  
  static const String locationUpdate = '/location/update';
  static const String locationBusCurrent = '/location/bus';
  static const String locationHistory = '/location/bus';
  static const String locationByTicket = '/location/ticket';
  
  static const String seatLock = '/seat-lock/lock';
  static const String seatUnlock = '/seat-lock/unlock';
  static const String seatLockMultiple = '/seat-lock/lock-multiple';
  static const String seatLockBus = '/seat-lock/bus';
  static const String seatLockMyLocks = '/seat-lock/my-locks';
  
  // Authentication
  static const String counterRegister = '/auth/register-bus-agent';
  static const String counterLogin = '/auth/login-bus-agent';
  static const String counterChangePassword = '/auth/bus-agent-change-password';
  static const String counterForgotPassword = '/auth/forgot-password-counter';
  static const String counterResetPassword = '/auth/reset-password-counter';
  
  // Counter/Agent
  static const String counterDashboard = '/counter/dashboard';
  
  // Profile Management
  static const String counterProfile = '/counter/profile';
  static const String counterMe = '/auth/me-bus-agent';
  
  // Counter Request Management (NEW)
  static const String counterRequestBusAccess = '/counter/request-bus-access'; // POST
  static const String counterRequests = '/counter/requests'; // GET
  
  // Bus Management - Assigned Buses
  static const String counterBuses = '/counter/buses'; // GET assigned buses
  static const String counterBusSearch = '/counter/buses/search'; // GET search by vehicle number
  static const String counterBusDetails = '/counter/buses'; // GET /:busId
  
  // Bus Management - Own Buses (LEGACY - Counters can no longer create buses, only owners can)
  // These endpoints are for managing legacy buses created by counters before the change
  static const String counterMyBuses = '/counter/buses/my-buses'; // GET own buses (legacy)
  static const String counterMyBusDetails = '/counter/buses/my-buses'; // GET /:busId (legacy)
  static const String counterBusCreate = '/counter/buses'; // POST to create bus (LEGACY - not recommended)
  static const String counterMyBusUpdate = '/counter/buses/my-buses'; // PUT /:busId (legacy)
  static const String counterMyBusDelete = '/counter/buses/my-buses'; // DELETE /:busId (legacy)
  // NOTE: Counters should use request-bus-access to get access to owner's buses instead
  
  // Booking Management
  static const String counterBookings = '/counter/bookings';
  static const String counterBookingCancel = '/counter/bookings'; // PUT /:bookingId/cancel
  static const String counterBookingsCancelMultiple = '/counter/bookings/cancel-multiple';
  static const String counterBookingUpdateStatus = '/counter/bookings'; // PATCH /:id/status
  
  // Driver Management
  static const String counterDriversInvite = '/counter/drivers/invite';
  static const String counterDrivers = '/counter/drivers';
  static const String counterDriverDetails = '/counter/drivers'; // GET /:driverId
  static const String counterDriverAssignBus = '/counter/drivers'; // PUT /:driverId/assign-bus
  static const String counterDriverUpdate = '/counter/drivers'; // PUT /:driverId
  static const String counterDriverDelete = '/counter/drivers'; // DELETE /:driverId
  
  // Schedule Management
  static const String counterSchedules = '/counter/schedules';
  static const String counterScheduleCreate = '/counter/schedules'; // POST
  static const String counterScheduleDetails = '/counter/schedules'; // GET /:scheduleId
  static const String counterScheduleUpdate = '/counter/schedules'; // PUT /:scheduleId
  static const String counterScheduleDelete = '/counter/schedules'; // DELETE /:scheduleId
  
  // Route Management
  static const String counterRoutes = '/counter/routes';
  static const String counterRouteCreate = '/counter/routes'; // POST to create route
  static const String counterRouteUpdate = '/counter/routes'; // PUT to update route
  static const String counterRouteDelete = '/counter/routes'; // DELETE to delete route
  
  // Wallet Management
  static const String counterWalletAdd = '/counter/wallet/add';
  static const String counterWalletTransactions = '/counter/wallet/transactions';
  
  // Notifications
  static const String counterNotifications = '/counter/notifications';
  static const String counterNotificationsMarkRead = '/counter/notifications/mark-read';
  static const String counterNotificationsMarkAllRead = '/counter/notifications/mark-all-read';
  static const String counterNotificationDelete = '/counter/notifications'; // DELETE /:id
  static const String counterNotificationsDeleteAll = '/counter/notifications'; // DELETE all
  
  // Sales & Reports
  static const String counterSalesSummary = '/counter/sales/summary';
  
  // Offline Mode
  static const String counterOfflineQueue = '/counter/offline/queue';
  static const String counterOfflineSync = '/counter/offline/sync';
  
  // Audit Logs
  static const String counterAuditLogs = '/counter/audit-logs';
  
  // Headers
  static const String authorizationHeader = 'Authorization';
  static const String contentTypeHeader = 'Content-Type';
  static const String contentTypeJson = 'application/json';
  static const String bearerPrefix = 'Bearer ';
  
  // Timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int multipartTimeout = 300000; // 300 seconds (5 minutes) for large file uploads (registration with images)
}

