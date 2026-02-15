import '../constants/app_constants.dart';

/// Utility helpers for normalizing and validating Nepal phone numbers.
///
/// Backend and Aakash SMS both expect a 10‑digit Nepal mobile number
/// in the form `98XXXXXXXX`. Clients, however, may send variants like:
/// - `98XXXXXXXX`
/// - `97798XXXXXXXX`
/// - `+97798XXXXXXXX`
/// - With spaces/dashes/parentheses
///
/// This helper converts most reasonable inputs into the canonical
/// 10‑digit format when possible. If normalization fails, it returns
/// the trimmed original so the caller can decide how to handle it.
class PhoneNormalizer {
  /// Normalize a phone string to a 10‑digit Nepal mobile number
  /// (`98XXXXXXXX`) when possible.
  ///
  /// - Strips all non‑digits.
  /// - Handles `977` / `+977` prefixes by keeping the last 10 digits.
  /// - Ensures the normalized value starts with `98` and has length 10.
  /// - If normalization is not possible, returns the original trimmed input.
  static String normalizeNepalPhone(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return trimmed;

    // Keep digits only.
    final digitsOnly = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return trimmed;

    String candidate = digitsOnly;

    // If the user included country code (977...), keep the last 10 digits.
    if (candidate.length > AppConstants.minPhoneLength &&
        (candidate.startsWith('977') || candidate.startsWith('0977'))) {
      // Drop any leading 0 before 977 (e.g. 0977...)
      if (candidate.startsWith('0977')) {
        candidate = candidate.substring(1);
      }
      if (candidate.length > AppConstants.minPhoneLength) {
        candidate = candidate.substring(candidate.length - AppConstants.minPhoneLength);
      }
    }

    // If we already have a 10‑digit number, keep as is.
    if (candidate.length == AppConstants.minPhoneLength &&
        candidate.startsWith('98')) {
      return candidate;
    }

    // Fallback: if length > 10, try last 10 digits and validate.
    if (candidate.length > AppConstants.minPhoneLength) {
      final last10 = candidate.substring(candidate.length - AppConstants.minPhoneLength);
      if (last10.startsWith('98')) {
        return last10;
      }
    }

    // Normalization failed – return original trimmed input so the caller
    // can surface a proper validation error if needed.
    return trimmed;
  }

  /// Returns true if [phone] is already in canonical `98XXXXXXXX` format.
  static bool isValidNormalizedNepalMobile(String phone) {
    final p = phone.trim();
    return p.length == AppConstants.minPhoneLength && p.startsWith('98');
  }
}

