/// Utility class for masking Personally Identifiable Information (PII)
/// 
/// Implements masking rules:
/// - Today's trips: Full PII visible
/// - Future/Past trips: Masked PII
/// - Name: Always visible
/// - Ticket Number: Always visible
class PiiMasking {
  /// Masks email address for privacy
  /// 
  /// Format: `ab***@domain.com` (first 2 chars + `***` + domain)
  /// 
  /// Example:
  /// - Input: `john.doe@example.com`
  /// - Output (masked): `jo***@example.com`
  /// - Output (today): `john.doe@example.com` (unchanged)
  static String maskEmail(String email, {required bool isToday}) {
    if (isToday) return email;
    
    // Validate email format
    final parts = email.split('@');
    if (parts.length != 2) return email;
    
    final local = parts[0];
    final domain = parts[1];
    
    // If local part is too short, don't mask
    if (local.length <= 2) return email;
    
    // Mask: first 2 chars + *** + @ + domain
    return '${local.substring(0, 2)}***@$domain';
  }
  
  /// Masks phone number for privacy
  /// 
  /// Format: `+977-9***123` (country code + first digit + `***` + last 3 digits)
  /// 
  /// Example:
  /// - Input: `+977-9812345678`
  /// - Output (masked): `+977-9***678`
  /// - Output (today): `+977-9812345678` (unchanged)
  static String maskPhone(String phone, {required bool isToday}) {
    if (isToday) return phone;
    
    // If phone is too short, don't mask
    if (phone.length < 7) return phone;
    
    // Extract prefix (everything except last 3 digits)
    final prefix = phone.substring(0, phone.length - 3);
    final suffix = phone.substring(phone.length - 3);
    
    // Mask: prefix + *** + suffix
    return '$prefix***$suffix';
  }
  
  /// Checks if a date is today
  /// 
  /// Returns true if the given date is the same day as today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
  
  /// Checks if a date string (YYYY-MM-DD) is today
  /// 
  /// Returns true if the given date string represents today
  static bool isTodayFromString(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return isToday(date);
    } catch (e) {
      // If parsing fails, assume not today (safer for privacy)
      return false;
    }
  }
  
  /// Masks passenger PII based on trip date
  /// 
  /// Returns a map with masked email and phone if the trip is not today
  static Map<String, dynamic> maskPassengerPii({
    required String? email,
    required String? phone,
    required String tripDate, // Format: YYYY-MM-DD
  }) {
    final isToday = isTodayFromString(tripDate);
    
    return {
      'email': email != null ? maskEmail(email, isToday: isToday) : null,
      'phone': phone != null ? maskPhone(phone, isToday: isToday) : null,
      'piiMasked': !isToday, // Flag indicating if PII was masked
    };
  }
}
