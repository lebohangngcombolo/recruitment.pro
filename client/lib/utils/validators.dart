class Validators {
  static String? requiredField(String? value) {
    if (value == null || value.isEmpty) return 'This field is required';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  static String? confirmPassword(String? value, String originalPassword) {
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    if (!RegExp(
      r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$',
    ).hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? url(String? value) {
    if (value != null &&
        value.isNotEmpty &&
        !RegExp(r'^(http|https)://[^ "]+$').hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  static String? number(String? value) {
    if (value != null &&
        value.isNotEmpty &&
        !RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Please enter a valid number';
    }
    return null;
  }

  static String? decimal(String? value) {
    if (value != null &&
        value.isNotEmpty &&
        !RegExp(r'^[0-9]+(\.[0-9]+)?$').hasMatch(value)) {
      return 'Please enter a valid decimal number';
    }
    return null;
  }
}
