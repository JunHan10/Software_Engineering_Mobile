// lib/services/money_service.dart
import 'package:intl/intl.dart';

/// Utility for formatting/parsing Hippo Bucks.
/// We store money as integer cents to avoid floating-point errors.
class MoneyService {
  // "HB" with 2 decimals; currency code is arbitrary ("HBUX")
  static final NumberFormat _fmt =
  NumberFormat.currency(symbol: 'HB ', decimalDigits: 2, name: 'HBUX');

  /// Format an integer number of cents to "HB X.YY"
  static String formatCents(int cents) => _fmt.format(cents / 100);

  /// Parse a user-entered string like "12.34" or "HB 12.34" to cents
  static int parseToCents(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9.]'), '');
    final val = double.tryParse(cleaned) ?? 0.0;
    return (val * 100).round();
  }
}
