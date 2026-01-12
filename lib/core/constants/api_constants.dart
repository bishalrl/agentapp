class ApiConstants {
  // Base URLs
  // ⚠️ IMPORTANT: Update this to your actual server IP address
  // For local development, use: http://YOUR_IP_ADDRESS:5000/api
  // Example: http://192.168.1.100:5000/api
  // To find your IP: Windows (ipconfig) or Mac/Linux (ifconfig)
  static const String baseUrl = 'http://192.168.254.13:5000/api'; // ⚠️ CHANGE THIS TO YOUR SERVER IP!
  static const String devBaseUrl = 'http://192.168.254.13:5000/api';
  
  // Production URL (only use if server is properly deployed)
  // static const String baseUrl = 'https://api.neelosewa.com/api';
  
  // API Endpoints
  static const String driverInvite = '/driver/invite';
  static const String driverVerifyOtp = '/driver/verify-otp';
  static const String driverProfile = '/driver/profile';
  static const String driverAssignedBuses = '/driver/assigned-buses';
  static const String driverLocationStart = '/driver/location/start';
  static const String driverLocationStop = '/driver/location/stop';
  static const String driverTripStatus = '/driver/trip-status';
  
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
  
  // Bus Management - Assigned Buses
  static const String counterBuses = '/counter/buses'; // GET assigned buses
  static const String counterBusDetails = '/counter/buses'; // GET /:busId
  
  // Bus Management - Own Buses
  static const String counterMyBuses = '/counter/buses/my-buses'; // GET own buses
  static const String counterMyBusDetails = '/counter/buses/my-buses'; // GET /:busId
  static const String counterBusCreate = '/counter/buses'; // POST to create bus
  static const String counterMyBusUpdate = '/counter/buses/my-buses'; // PUT /:busId
  static const String counterMyBusDelete = '/counter/buses/my-buses'; // DELETE /:busId
  
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
}

