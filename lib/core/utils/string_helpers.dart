extension StringHelpers on String {
  bool get isNullOrEmpty => isEmpty;
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
