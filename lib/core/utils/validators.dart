class Validators {
  Validators._();

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static bool isValidEmail(String value) => _emailPattern.hasMatch(value.trim());

  static bool isNotEmpty(String? value) => value != null && value.trim().isNotEmpty;
}
