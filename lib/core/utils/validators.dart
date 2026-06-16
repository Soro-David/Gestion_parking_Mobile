class Validators {
  static bool isEmail(String? value) {
    if (value == null) return false;
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    return emailRegex.hasMatch(value);
  }
}
