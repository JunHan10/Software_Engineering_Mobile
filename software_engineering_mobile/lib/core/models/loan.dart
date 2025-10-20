/// Loan Model - Represents an active loan between users
/// 
/// This class tracks loans where one user has borrowed an item from another user.
/// It includes loan details, status, and timestamps for proper management.
class Loan {
  final String? id; // Database ID
  final String itemId; // ID of the borrowed item
  final String itemName; // Name of the borrowed item
  final String itemDescription; // Description of the borrowed item
  final String itemImagePath; // Image path of the borrowed item
  final String ownerId; // ID of the item owner
  final String ownerName; // Name of the item owner
  final String borrowerId; // ID of the borrower
  final String borrowerName; // Name of the borrower
  final DateTime startDate; // When the loan started
  final DateTime? endDate; // When the loan ended (null if still active)
  final DateTime? expectedReturnDate; // When the item should be returned
  final LoanStatus status; // Current status of the loan
  final String? notes; // Additional notes about the loan
  final double itemValue; // Value of the borrowed item

  const Loan({
    this.id,
    required this.itemId,
    required this.itemName,
    required this.itemDescription,
    required this.itemImagePath,
    required this.ownerId,
    required this.ownerName,
    required this.borrowerId,
    required this.borrowerName,
    required this.startDate,
    this.endDate,
    this.expectedReturnDate,
    this.status = LoanStatus.active,
    this.notes,
    required this.itemValue,
  });

  /// Factory constructor for creating Loan objects from JSON data
  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['_id'] ?? json['id'],
      itemId: json['itemId'] ?? '',
      itemName: json['itemName'] ?? '',
      itemDescription: json['itemDescription'] ?? '',
      itemImagePath: json['itemImagePath'] ?? '',
      ownerId: json['ownerId'] ?? '',
      ownerName: json['ownerName'] ?? '',
      borrowerId: json['borrowerId'] ?? '',
      borrowerName: json['borrowerName'] ?? '',
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      expectedReturnDate: json['expectedReturnDate'] != null 
          ? DateTime.tryParse(json['expectedReturnDate']) 
          : null,
      status: LoanStatus.values.firstWhere(
        (e) => e.toString() == 'LoanStatus.${json['status']}',
        orElse: () => LoanStatus.active,
      ),
      notes: json['notes'],
      itemValue: (json['itemValue'] ?? 0.0).toDouble(),
    );
  }

  /// Converts Loan object to JSON Map for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemId': itemId,
      'itemName': itemName,
      'itemDescription': itemDescription,
      'itemImagePath': itemImagePath,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'borrowerId': borrowerId,
      'borrowerName': borrowerName,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'expectedReturnDate': expectedReturnDate?.toIso8601String(),
      'status': status.toString().split('.').last,
      'notes': notes,
      'itemValue': itemValue,
    };
  }

  /// Create a copy of the loan with updated values
  Loan copyWith({
    String? id,
    String? itemId,
    String? itemName,
    String? itemDescription,
    String? itemImagePath,
    String? ownerId,
    String? ownerName,
    String? borrowerId,
    String? borrowerName,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? expectedReturnDate,
    LoanStatus? status,
    String? notes,
    double? itemValue,
  }) {
    return Loan(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      itemDescription: itemDescription ?? this.itemDescription,
      itemImagePath: itemImagePath ?? this.itemImagePath,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      borrowerId: borrowerId ?? this.borrowerId,
      borrowerName: borrowerName ?? this.borrowerName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      expectedReturnDate: expectedReturnDate ?? this.expectedReturnDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      itemValue: itemValue ?? this.itemValue,
    );
  }

  /// Check if the loan is overdue
  bool get isOverdue {
    if (expectedReturnDate == null || status != LoanStatus.active) return false;
    return DateTime.now().isAfter(expectedReturnDate!);
  }

  /// Get the duration of the loan in days
  int get durationInDays {
    final end = endDate ?? DateTime.now();
    return end.difference(startDate).inDays;
  }

  /// Get a formatted status string
  String get statusDisplayName {
    switch (status) {
      case LoanStatus.active:
        return isOverdue ? 'Overdue' : 'Active';
      case LoanStatus.completed:
        return 'Completed';
      case LoanStatus.cancelled:
        return 'Cancelled';
      case LoanStatus.returned:
        return 'Returned';
    }
  }
}

/// Enum for loan status
enum LoanStatus {
  active,      // Loan is currently active
  completed,   // Loan has been completed successfully
  cancelled,   // Loan was cancelled
  returned,    // Item has been returned
}
