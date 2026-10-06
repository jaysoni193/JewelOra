class Validators {
  Validators._();

  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name is too short';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w\.\-+]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  /// Phone is optional. If entered, it must be 10 digits.
  static String? optionalPhone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
      return 'Enter a valid 10 digit number';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? Function(String?) confirmPassword(String Function() original) {
    return (value) {
      if (value == null || value.isEmpty) return 'Confirm your password';
      if (value != original()) return 'Passwords do not match';
      return null;
    };
  }

  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) return 'Price is required';
    final n = double.tryParse(value.trim());
    if (n == null) return 'Enter a valid number';
    if (n <= 0) return 'Price must be greater than 0';
    return null;
  }

  /// Digits only, with country code (e.g. 919876543210).
  static String? whatsapp(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return 'WhatsApp number is required';
    if (digits.length < 11 || digits.length > 15) {
      return 'Include country code, e.g. 919876543210';
    }
    return null;
  }
}