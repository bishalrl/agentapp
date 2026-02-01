/// Utility class for formatting vehicle numbers (Nepal standard)
class VehicleNumberFormatter {
  /// Formats vehicle number to Nepal standard: BA-01-KHA-1234
  /// Accepts various input formats and converts to standard format
  static String format(String input) {
    // Remove all spaces and convert to uppercase
    String cleaned = input.replaceAll(RegExp(r'\s+'), '').toUpperCase();
    
    // Remove existing dashes
    cleaned = cleaned.replaceAll('-', '');
    
    // Pattern: 2 letters, 2 digits, 3 letters, 4 digits (e.g., BA01KHA1234)
    if (cleaned.length >= 11) {
      // Extract parts
      String part1 = cleaned.substring(0, 2); // BA
      String part2 = cleaned.substring(2, 4); // 01
      String part3 = cleaned.length >= 7 ? cleaned.substring(4, 7) : cleaned.substring(4); // KHA
      String part4 = cleaned.length >= 11 ? cleaned.substring(7, 11) : (cleaned.length > 7 ? cleaned.substring(7) : ''); // 1234
      
      // Format: BA-01-KHA-1234
      if (part4.isNotEmpty) {
        return '$part1-$part2-$part3-$part4';
      } else if (part3.isNotEmpty) {
        return '$part1-$part2-$part3';
      } else {
        return '$part1-$part2';
      }
    }
    
    // If input is too short, return as is (user can continue typing)
    return cleaned;
  }
  
  /// Validates if vehicle number matches Nepal standard format
  static bool isValid(String input) {
    if (input.isEmpty) return false;
    
    // Pattern: XX-XX-XXX-XXXX or variations
    final pattern = RegExp(r'^[A-Z]{2}-?\d{2}-?[A-Z]{2,3}-?\d{3,4}$', caseSensitive: false);
    return pattern.hasMatch(input.replaceAll(RegExp(r'\s+'), ''));
  }
}
