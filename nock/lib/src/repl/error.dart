class NockError implements Exception {
  final String message;
  NockError(this.message);

  @override
  String toString() => 'NockError: $message';
}
