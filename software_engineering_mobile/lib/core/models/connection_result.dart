class ConnectionResult {
  final bool success;
  final String message;

  const ConnectionResult({required this.success, required this.message});

  Map<String, dynamic> toJson() => {'success': success, 'message': message};
}
