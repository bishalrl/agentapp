class AppConstants {
  // App Info
  static const String appName = 'Neelo Sewa Agent';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String onboardingKey = 'onboarding_completed';
  // Distinguish whether the current auth token belongs to counter or driver
  // Valid values: 'counter', 'driver'
  static const String sessionTypeKey = 'session_type';
  
  // Timeouts
  static const int otpExpirationMinutes = 10;
  static const int seatLockExpirationMinutes = 10;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Validation
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
}

